library(dplyr)
library(ggplot2)

# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/date_functions.r")

# get value at risk
get_value_at_risk <- function(data_frame, returns_column_name = "dailyreturns", alpha) {
    # sort returns by size
    data_frame_sorted <- data_frame[order(data_frame[, returns_column_name], decreasing = TRUE), ]

    value_at_risk <- quantile(data_frame_sorted[, returns_column_name], alpha)

    return(value_at_risk)
}

# calculate value at risk for each day
get_value_at_risk_for_target_date <- function(data_frame,
                                              target_date,
                                              observation_period = 250,
                                              date_column_name = "date",
                                              returns_column_name = "dailyreturns",
                                              alpha = 0.01) {
    target_date <- as.Date(target_date)
    start_date <- subtract_days(target_date, observation_period + 1)
    end_date <- subtract_days(target_date, 1)

    # get subset of dataframe to calculate value at risk
    subset <- get_data_frame_subset(data_frame,
        start_date,
        end_date,
        date_column_name = date_column_name
    )
    var <- get_value_at_risk(subset, returns_column_name, alpha)
    return(var)
}

# backtesting function -> calculates VaR for each day
# data frame has to expand 250 days before the first day of the backtesting period
calculate_var_for_data_frame <- function(data_frame,
                                         observation_period = 250,
                                         date_column_name = "date",
                                         returns_column_name = "dailyreturns",
                                         alpha = 0.01) {
    # calculate value at risk for each day
    data_frame$var <- apply(data_frame, 1, function(x) {
        get_value_at_risk_for_target_date(data_frame,
            getElement(x, date_column_name),
            observation_period,
            date_column_name = date_column_name,
            returns_column_name = returns_column_name,
            alpha = alpha
        )
    })

    # trim bad data from the beginning of the data frame
    # data is bad because the calculation assumes that the daily returns of the first 250 days are 0
    # you can only use this data past the 250th day
    actual_data_frame <- get_data_frame_subset(data_frame, start_date, end_date, date_column_name)

    return(actual_data_frame)
}

get_overshoots <- function(data_frame,
                           returns_column_name = "dailyreturns",
                           var_column_name = "var") {
    # get all overshoots
    overshoots <- data_frame[data_frame[[returns_column_name]] < data_frame[[var_column_name]], ]
    return(overshoots)
}

plot_overshoots <- function(data_frame,
                            returns_column_name = "dailyreturns",
                            var_column_name = "var",
                            title = "Overshoots") {
    # plot returns together with value at risk
    ggplot(data_frame, aes(x = date)) +
        geom_point(aes(y = returns_column_name), color = "blue", size = 3) +
        geom_line(aes(y = var_column_name), color = "red", size = 1) +
        labs(
            title = title,
            x = "Date",
            y = "Daily Returns"
        )
}

# LIMIT TESTING
test_var_limit_by_holding_period <- function(data_frame,
                                             target_date,
                                             observation_period = 250,
                                             date_column_name = "date",
                                             returns_column_name = "dailyreturns",
                                             alpha = 0.01,
                                             holding_period = 20) {
    var <- get_value_at_risk_for_target_date(data_frame,
        target_date,
        observation_period,
        alpha = alpha
    )
    var_after_holding_period <- var * sqrt(holding_period)
    return(var_after_holding_period)
}
