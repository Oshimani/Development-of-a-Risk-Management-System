# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/common.r")

# CONSTANTS
# OBSERVATION PERIOD
start_date <- "2020-12-11"
end_date <- "2020-12-31"

alpha <- 0.01

# GET PRICES FROM DATABASE
deutsche_bank_data <- get_prices(start_date, end_date, DEUTSCHE_BANK_ISIN)

# CALCULATE VALUE AT RISK
deutsche_bank_value_at_risk <- get_value_at_risk(deutsche_bank_data, "dailyreturns", alpha)
deutsche_bank_value_at_risk
