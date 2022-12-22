library(ggplot2)
library(tidyr)
library(dplyr)

source("./Database/DatabaseController/common.r")
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/date_functions.r")

# Get all trades from database that belong to a specific portfolio
get_trades_by_portfolio_name <- function(portfolio_name) {
    query <- sprintf(
        paste(
            "SELECT * FROM v_trades",
            "WHERE name = '%s'",
            "ORDER BY date ASC"
        ),
        portfolio_name
    )
    trades <- dbGetQuery(CONNECTION, query)
    return(trades)
}

# Get the amount of a certain stock in a portfolio at a certain date
# param trades must only contain trades from this portfolio
get_stock_in_portfolio_at_date <- function(trades, isin, date) {
    # filter trades by date and isin
    stock_trades <- trades[trades$isin == isin & trades$date <= date, ]
    # print(sprintf("Found %i stock trades for %s", nrow(stock_trades), isin))

    # sum up the amount of stocks
    stock_amount <- sum(stock_trades$amount)
    return(stock_amount)
}

# gets the amount of stocks in a portfolio for a given date
get_portfolio_state_at_date <- function(trades, date) {
    # get unique isins in portfolio
    isins <- unique(trades$isin)
    # print(sprintf("Found %i unique stock(s) in portfolio", length(isins)))

    # for each isin get stock amount
    stock_amounts <- lapply(isins, function(isin) {
        get_stock_in_portfolio_at_date(trades, isin, date)
    })
    # convert to data frame
    stock_amounts_df <- data.frame(
        isin = isins,
        amount = unlist(stock_amounts),
        date = date
    )

    return(stock_amounts_df)
}

# gets the portfolio states over time
# only dates of action are returned
get_portfolio_state_as_timeseries <- function(trades) {
    # get dates of action in portfolio (date on which a trade was made)
    dates <- unique(trades$date)

    # for each date get portfolio state
    portfolio_states <- lapply(dates, function(date) {
        get_portfolio_state_at_date(trades, date)
    })
    # convert to data frame
    portfolio_states_df <- do.call(rbind, portfolio_states)

    return(portfolio_states_df)
}

# gets the portfolio states over time
# includes all trading days
get_portfolio_as_timeseries <- function(portfolio_name) {
    # get trades from database
    portfolio_name <- "Portfolio von Jannick"
    trades <- get_trades_by_portfolio_name(portfolio_name)
    # print(sprintf("%s contains %i trades", portfolio_name, nrow(trades)))

    # get portfolio state over time
    portfolio_states <- get_portfolio_state_as_timeseries(trades)

    # as portfolio_states only contains days with trading action, we need to fill the gaps

    # day of first trade with this portfolio, before VaR is 0 because NAV is 0
    first_trade_date <- min(trades$date)
    # last day for which we have prices
    last_valid_date <- get_last_price_date()
    # get all trading dates
    all_dates <- get_all_trading_dates_in_period(first_trade_date, last_valid_date)

    # get all isins in portfolio
    isins <- unique(trades$isin)

    for (isin in isins) {
        current_stock_df <- portfolio_states[portfolio_states$isin == isin, ]
        # get all dates for which we have no data
        missing_dates <- subset(all_dates, !(date %in% current_stock_df$date))
        # append missing dates to current_stock_df
        current_stock_df <- rbind(current_stock_df, data.frame(
            isin = isin,
            amount = NA,
            date = missing_dates
        ))

        # sort by date
        current_stock_df <- current_stock_df[order(current_stock_df$date, decreasing = FALSE), ]

        # fill NA values with latest non na value
        current_stock_df <- current_stock_df %>% fill(amount)

        # remove all trades with this isin
        portfolio_states <- portfolio_states[portfolio_states$isin != isin, ]
        # insert full timeline for this isin
        portfolio_states <- rbind(portfolio_states, current_stock_df)
    }

    # sort by date
    portfolio_states <- portfolio_states[order(portfolio_states$date, decreasing = FALSE), ]
    return(portfolio_states)
}

# plots the portfolio states over time
plot_portfolio_over_time <- function(portfolio_timeseries, heading = "Portfolio-Entwicklung") {
    ggplot(portfolio_timeseries, aes(x = date, y = amount, fill = isin)) +
        geom_bar(stat = "identity") +
        labs(title = heading, x = "Datum", y = "Anzahl")
}

plot_portfolio_trades_over_time <- function(trades, heading = "Trades") {
    ggplot(trades, aes(x = date, y = amount, fill = isin)) +
        geom_bar(stat = "identity") +
        labs(title = heading, x = "Datum", y = "Anzahl")
}

# gets the portfolio value and returns
# includes all trading days
get_daily_returns_and_value_for_portfolio_timeseries <- function(portfolio_data_frame) {
    # get first date
    start_date <- min(portfolio_data_frame$date)
    # get last date
    end_date <- max(portfolio_data_frame$date)
    # get prices for all stocks in portfolio
    prices <- get_all_prices(start_date, end_date)

    # add close price to dataframe
    portfolio_data_frame <- merge(portfolio_data_frame, prices, by = c("isin", "date"))
    # rename daily returns to dailyreturns_single_stock
    names(portfolio_data_frame)[names(portfolio_data_frame) == "dailyreturns"] <- "dailyreturns_single_stock"
    # calculate daily returns for the amount of stock owned
    portfolio_data_frame$dailyreturns_portfolio_abs <- portfolio_data_frame$amount *
        portfolio_data_frame$dailyreturns_single_stock *
        portfolio_data_frame$close
    # get position value
    portfolio_data_frame$position_value <- portfolio_data_frame$amount * portfolio_data_frame$close

    # sort by date
    portfolio_data_frame <- portfolio_data_frame[order(portfolio_data_frame$date, decreasing = FALSE), ]

    # get daily returns and total value for portfolio
    portfolio_daily_returns <- portfolio_data_frame %>%
        group_by(date) %>%
        summarize(
            dailyreturns_portfolio_abs = sum(dailyreturns_portfolio_abs),
            position_value = sum(position_value)
        ) %>%
        ungroup()

    # rename position_value to total_value
    names(portfolio_daily_returns)[names(portfolio_daily_returns) == "position_value"] <- "total_value"

    # calculate relative daily returns
    portfolio_daily_returns$dailyreturns_portfolio <- portfolio_daily_returns$dailyreturns_portfolio_abs /
        portfolio_daily_returns$total_value

    return(portfolio_daily_returns)
}

plot_daily_returns_for_portfolio_timeseries <- function(portfolio_data_frame, heading = "Tagesrenditen") {
    # get daily returns
    portfolio_data_frame <- get_daily_returns_and_value_for_portfolio_timeseries(portfolio_data_frame)

    # plot daily returns
    # use green when daily return is positive, red when negative
    ggplot(portfolio_data_frame, aes(x = date, y = dailyreturns_portfolio)) +
        geom_bar(stat = "identity", fill = ifelse(portfolio_data_frame$dailyreturns_portfolio > 0, "#009b00", "#e20000")) +
        labs(title = heading, x = "Datum", y = "Tagesrendite")
}

# #################################################
# THE MAIN FUNCTION TO BE USED OUTSIDE OF THIS FILE
# returns portfolio value and daily returns
# includes all trading days
# starts at portfolio creation date (first trade)
# ends at last known trading day
get_portfolio <- function(portfolio_name) {
    pf_ts <- get_portfolio_as_timeseries(portfolio_name)
    pf <- get_daily_returns_and_value_for_portfolio_timeseries(pf_ts)

    # rename dailyreturns_portfolio to dailyreturns
    names(pf)[names(pf) == "dailyreturns_portfolio"] <- "dailyreturns"
    # rename dailyreturns_portfolio_abs to dailyreturns_abs
    names(pf)[names(pf) == "dailyreturns_portfolio_abs"] <- "dailyreturns_abs"

    return(data.frame(pf))
}

# get amounts of stock held at target date
get_portfolio_weights_at_target_date <- function(portfolio_name, target_date) {
    print(target_date)
    pf <- get_trades_by_portfolio_name(portfolio_name)
    # get only trades before target date
    pf <- pf[pf$date <= target_date, ]

    # sum trades by isin
    pf_weights <- pf %>%
        group_by(isin) %>%
        summarize(
            amount = sum(amount)
        ) %>%
        ungroup()

    pf_weights <- data.frame(pf_weights)

    # add date
    pf_weights$date <- target_date

    # fetch prices for target date
    prices <- get_all_prices(target_date, target_date)

    # merge both tables
    pf_weights <- merge(pf_weights, prices, by = "isin")
    # rename date.x to date
    names(pf_weights)[names(pf_weights) == "date.x"] <- "date"
    # remove date.y
    pf_weights$date.y <- NULL

    # calculate value of stocks
    pf_weights$value <- pf_weights$amount * pf_weights$close

    # calculate weight of stocks
    pf_weights$weight <- pf_weights$value / sum(pf_weights$value)

    return(pf_weights)
}

# #################################################
# THIS SECTION IS ONLY FOR GENERATION MOCK DATA

create_portfolio <- function(name) {
    query <- sprintf(
        paste(
            "INSERT INTO t_portfolios (name)",
            "VALUES ('%s')"
        ),
        name
    )
    res <- dbSendQuery(CONNECTION, query)
    dbClearResult(res)
}

delete_portfolio <- function(name) {
    query <- sprintf(
        "DELETE FROM t_portfolios WHERE name = '%s'",
        name
    )
    res <- dbSendQuery(CONNECTION, query)
    dbClearResult(res)
}

trade_stock <- function(type, portfolio_name, isin, amount, date) {
    # prevent bad data
    if (amount <= 0) {
        return()
    }

    # using keywords to trade for better readability
    if (type == "sell") {
        amount <- -amount
    }

    query <- sprintf(
        paste(
            "INSERT INTO t_portfolios_stocks (portfolio_id, stock_isin, amount, date)",
            "VALUES ((",
            "SELECT id FROM t_portfolios",
            "WHERE name = '%s'",
            "), '%s', %i, '%s')"
        ),
        portfolio_name, isin, amount, date
    )
    res <- dbSendQuery(CONNECTION, query)
    dbClearResult(res)
}
