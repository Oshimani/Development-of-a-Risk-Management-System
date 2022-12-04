# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./Database/DatabaseController/portfolios.r")
source("./DataAnalysis/common.r")
source("./DataAnalysis/date_functions.r")
source("./DataAnalysis/value_at_risk.r")

# CONSTANTS
# OBSERVATION PERIOD
end_date <- as.Date("2022-01-01")
duration <- 365
start_date <- subtract_days(end_date, duration)

alpha <- 0.01
var_observation_period <- 250

# also fetch enough data to calculate the first few days of var
historical_data_start_date <- get_required_start_date(start_date, var_observation_period)
historical_data_end_date <- as.Date(end_date)

portfolio <- get_portfolio("Portfolio von Jannick")

portfolio$date <- as.Date(portfolio$date)

# backtesting
 portfolio_backtested <- calculate_var_for_data_frame(portfolio,
                                                      observation_period = var_observation_period,
                                                      alpha = alpha)
