library(dplyr)
library(ggplot2)

# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/common.r")
source("./DataAnalysis/date_functions.r")

# observation period
end_date <- as.Date("2022-01-01")
duration <- 365
start_date <- subtract_days(end_date, duration)

alpha <- 0.05
var_observation_period <- 100

# also fetch enough data to calculate the first few days of var
historical_data_start_date <- subtract_days(start_date, var_observation_period)
historical_data_end_date <- as.Date(end_date)

# get prices from database
deutsche_bank_data <- get_prices(
    historical_data_start_date,
    historical_data_end_date,
    DEUTSCHE_BANK_ISIN
)

# calculate value at risk for each day
get_value_at_risk_for_target_date <- function(data_frame,
                                              target_date,
                                              observation_period,
                                              date_column_name = "date",
                                              returns_column_name = "dailyreturns",
                                              alpha) {
    start_date <- subtract_days(target_date, observation_period + 1)
    end_date <- subtract_days(target_date, 1)

    # get subset of dataframe to calculate value at risk
    subset <- get_data_frame_subset(data_frame, start_date, end_date, "date")
    var <- get_value_at_risk(subset, returns_column_name, alpha)
    # print value at risk
    print(paste("var:", var))
    return(var)
}


deutsche_bank_data$var <- apply(deutsche_bank_data, 1, function(x) {
    get_value_at_risk_for_target_date(deutsche_bank_data, getElement(x, "date"), var_observation_period, alpha = alpha)
})

# limit to observation period
deutsche_bank_data <- get_data_frame_subset(deutsche_bank_data, start_date, end_date, "date")



# calculate value at risk for each day in data frame by observation period and add to data frame
# deutsche_bank_data <- deutsche_bank_data %>%
#     mutate(
#         var = get_value_at_risk_for_target_date(
#             deutsche_bank_data,
#             date,
#             var_observation_period,
#             "date",
#             "dailyreturns",
#             alpha
#         )
#     )

# get all overshoots
overshoots <- deutsche_bank_data[deutsche_bank_data$dailyreturns < deutsche_bank_data$var, ]
print(overshoots)

# plot returns together with value at risk
ggplot(deutsche_bank_data, aes(x = date)) +
    geom_point(aes(y = dailyreturns), color = "blue", size = 3) +
    geom_line(aes(y = var), color = "red", size = 1) +
    labs(
        title = "Value at Risk for Deutsche Bank",
        x = "Date",
        y = "Returns"
    )
