# LOCAL IMPORTS
source("./Database/DatabaseController/common.r")
source("./Database/DatabaseController/portfolios.r")
source("./DataAnalysis/date_functions.r")

set.seed(2022)

# calculate how many stocks can be sold at max
get_maximum_sell <- function(data_frame, isin) {
  current_stock_trades <- data_frame[data_frame$isin == isin, ]
  # get all buys & sells
  buys <- sum(current_stock_trades[current_stock_trades$type == "buy", ]$amount)
  sells <- sum(current_stock_trades[current_stock_trades$type == "sell", ]$amount)
  maximum_sell <- buys - sells
  # print max sell
  return(maximum_sell)
}

get_random_trades <- function(dates,
                              list_of_isins,
                              list_of_trade_types,
                              buy_factor,
                              sell_factor,
                              max_buy_amount,
                              max_sell_amount) {
  # create empty data frame
  trades <- data.frame(
    date = character(),
    isin = character(),
    amount = integer(),
    type = character()
  )
  # generate trades that cannot go below 0
  for (date in dates$date) {
    # get random isin
    isin <- sample(list_of_isins, 1, replace = TRUE)
    trade_type <- sample(list_of_trade_types, 1, replace = TRUE)
    amount <- -1

    if (trade_type == "sell") {
      # selling
      max_amount <- get_maximum_sell(trades, isin)
      if (max_amount == 0) {
        # no stocks to sell so buy some instead
        trade_type <- "buy"
      } else {
        max <- min(max_amount, max_sell_amount) * sell_factor
        amount <- sample(1:max, 1, replace = TRUE)
      }
    }
    if (trade_type == "buy") {
      # buying
      max <- max_buy_amount * buy_factor
      amount <- sample(1:max, 1, replace = FALSE)
    }

    # add trade to data frame
    trades <- rbind(trades, data.frame(
      type = trade_type,
      amount,
      isin,
      date = as.Date(date, origin = "1970-01-01")
    ))
  }
  return(trades)
}

get_random_trades_in_date_period <- function(start_date,
                                             end_date,
                                             amount_of_dates,
                                             list_of_isins = c(DEUTSCHE_BANK_ISIN, MERCEDES_BENZ_GROUP_ISIN),
                                             list_of_trade_types = c("buy", "sell"), # add more sells or buys to manipulate priorities
                                             buy_factor = 1, # 0-1, decrease buy amount
                                             sell_factor = 1, # 0-1, decrease sell amount
                                             max_buy_amount = 1000,
                                             max_sell_amount = 1000) {
  # get random dates
  random_dates <- data.frame(date = get_random_trading_dates(start_date, end_date, amount_of_dates))

  # get random trades
  trades <- get_random_trades(
    random_dates,
    list_of_isins,
    list_of_trade_types,
    buy_factor,
    sell_factor,
    max_buy_amount,
    max_sell_amount
  )
  return(trades)
}

# delete existing portfolios
delete_portfolio("Portfolio von Jannick")
delete_portfolio("Portfolio von Liwen")
delete_portfolio("Portfolio von Philipp")
delete_portfolio("Mercedes Benz")
delete_portfolio("Deutsche Bank")
delete_portfolio("Philipps Testportfolio")

# create new portfolios
create_portfolio("Portfolio von Jannick")
create_portfolio("Portfolio von Liwen")
create_portfolio("Portfolio von Philipp")
create_portfolio("Mercedes Benz")
create_portfolio("Deutsche Bank")
create_portfolio("Philipps Testportfolio")

# create trades for each portfolio
jannicks_trades <- get_random_trades_in_date_period(
  "2019-01-11",
  "2023-01-10",
  300,
  list_of_isins = c(DEUTSCHE_BANK_ISIN, MERCEDES_BENZ_GROUP_ISIN, MERCEDES_BENZ_GROUP_ISIN),
  list_of_trade_types = c("buy", "sell"),
  buy_factor = 1,
  sell_factor = 0.5,
  max_buy_amount = 1000,
  max_sell_amount = 1000
)

liwens_trades <- get_random_trades_in_date_period(
  "2020-01-01",
  "2022-11-01",
  200,
  list_of_isins = c(DEUTSCHE_BANK_ISIN, DEUTSCHE_BANK_ISIN, MERCEDES_BENZ_GROUP_ISIN),
  list_of_trade_types = c("buy", "sell"),
  buy_factor = 1,
  sell_factor = 1,
  max_buy_amount = 100,
  max_sell_amount = 100
)

plilipps_trades <- get_random_trades_in_date_period(
  "2021-01-01",
  "2021-12-31",
  100,
  list_of_isins = c(DEUTSCHE_BANK_ISIN, MERCEDES_BENZ_GROUP_ISIN),
  list_of_trade_types = c("buy", "buy", "buy", "sell"),
  buy_factor = 1,
  sell_factor = 1,
  max_buy_amount = 1000,
  max_sell_amount = 1000
)

mercedes_trades <- get_random_trades_in_date_period(
  "2021-01-01",
  "2022-11-01",
  100,
  list_of_isins = c(MERCEDES_BENZ_GROUP_ISIN),
  list_of_trade_types = c("buy", "sell"),
  buy_factor = 1,
  sell_factor = 0.5,
  max_buy_amount = 1000,
  max_sell_amount = 1000
)

deutsche_bank_trades <- get_random_trades_in_date_period(
  "2021-01-01",
  "2022-11-01",
  100,
  list_of_isins = c(DEUTSCHE_BANK_ISIN),
  list_of_trade_types = c("buy", "sell"),
  buy_factor = 1,
  sell_factor = 0.5,
  max_buy_amount = 1000,
  max_sell_amount = 1000
)

plilipps_trades_testportfolio <- get_random_trades_in_date_period(
  "2021-01-01",
  "2022-10-31",
  10,
  list_of_isins = c(DEUTSCHE_BANK_ISIN, MERCEDES_BENZ_GROUP_ISIN),
  list_of_trade_types = c("buy", "sell"),
  buy_factor = 2,
  sell_factor = 1,
  max_buy_amount = 10000,
  max_sell_amount = 10000
)

# save trades in database
save_trades <- function(trades, portfolio_name) {
  # iterate over trades
  for (i in 1:nrow(trades)) {
    trade <- trades[i, ]

    # save trade
    trade_stock(
      trade$type,
      portfolio_name,
      trade$isin,
      trade$amount,
      trade$date
    )
  }
}

save_trades(jannicks_trades, "Portfolio von Jannick")
save_trades(liwens_trades, "Portfolio von Liwen")
save_trades(plilipps_trades, "Portfolio von Philipp")
save_trades(mercedes_trades, "Mercedes Benz")
save_trades(deutsche_bank_trades, "Deutsche Bank")
save_trades(plilipps_trades_testportfolio, "Philipps Testportfolio")


# plot trades and portfolios
# plot_portfolio_over_time(get_portfolio_as_timeseries("Portfolio von Jannick"), "Portfolio von Jannick")
# plot_portfolio_over_time(get_portfolio_as_timeseries("Portfolio von Liwen"), "Portfolio von Liwen")
# plot_portfolio_over_time(get_portfolio_as_timeseries("Portfolio von Philipp"), "Portfolio von Philipp")
# plot_portfolio_over_time(get_portfolio_as_timeseries("Mercedes Benz"), "Portfolio von Mercedes Benz")
# plot_portfolio_over_time(get_portfolio_as_timeseries("Deutsche Bank"), "Portfolio von Deutsche Bank")
plot_portfolio_over_time(get_portfolio_as_timeseries("Philipps Testportfolio"), "Philipps Testportfolio")
