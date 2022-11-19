library(ggplot2)

source("./Database/DatabaseController/common.r")

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
    trades <- get_trades_by_portfolio_name(portfolio_name)
    print(sprintf("%s contains %i trades", portfolio_name,nrow(trades)))

    # get portfolio state over time
    portfolio_states <- get_portfolio_state_as_timeseries(trades)

    return(portfolio_states)
}

# plots the portfolio states over time
plot_portfolio_over_time <- function(portfolio_timeseries, heading="Portfolio-Entwicklung") {
    ggplot(portfolio_timeseries, aes(x = date, y = amount, fill = isin)) +
        geom_bar(stat = "identity") +
        labs(title = heading, x = "Datum", y = "Anzahl")
}

plot_portfolio_trades_over_time <- function(trades, heading="Trades") {
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
