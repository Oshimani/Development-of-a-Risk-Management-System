library(ggplot2)
library(tidyr)

source("./Database/DatabaseController/common.r")
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

# THIS IS THE MAIN FUNCTION TO BE USED FROM THIS FILE
# ---------------------------------------------------
get_portfolio_as_timeseries <- function(portfolio_name) {
    # get trades from database
    portfolio_name <- "Portfolio von Jannick"
    trades <- get_trades_by_portfolio_name(portfolio_name)
    print(sprintf("%s contains %i trades", portfolio_name, nrow(trades)))

    # get portfolio state over time
    portfolio_states <- get_portfolio_state_as_timeseries(trades)

    # as portfolio_states only contains days with trading action, we need to fill the gaps

    # day of first trade with this portfolio, before VaR is 0 because NAV is 0
    first_trade_date <- min(trades$date)
    # last day for which we have prices
    last_valid_date <- get_last_price_date()
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

# TEST THESE FUNCTIONS
# philipps_trades <- get_trades_by_portfolio_name("Portfolio von Philipp")
# jannicks_trades <- get_trades_by_portfolio_name("Portfolio von Jannick")
# philipps_deutsche <- get_stock_in_portfolio_at_date(philipps_trades, DEUTSCHE_BANK_ISIN, "2021-01-11")
# jannicks_deutsche <- get_stock_in_portfolio_at_date(jannicks_trades, DEUTSCHE_BANK_ISIN, "2022-11-19")
# get_portfolio_state_at_date(philipps_trades, "2021-01-20")
# jannicks_pf_timeseries <- get_portfolio_state_as_timeseries(jannicks_trades)
# plot_portfolio_over_time(jannicks_pf_timeseries)
# get_portfolio_as_timeseries("Portfolio von Jannick")

# EXAMPLES FOR PLOTTING FUNCTIONS
# plot_portfolio_over_time(get_portfolio_as_timeseries("Portfolio von Jannick"), "Portfolio von Jannick")
# plot_portfolio_trades_over_time(get_trades_by_portfolio_name("Portfolio von Philipp"), "Trades von Philipp")


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
