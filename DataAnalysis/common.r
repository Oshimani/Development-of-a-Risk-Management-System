### THIS FILE CONTAINS ALL COMMON MATHEMACICALLY FUNCTIONS

# calculate logarithmic daily returns
# close_column_name = the name of the column containing the closing price
# stetige/ kontinuierliche rendite
get_continuous_daily_returns <- function(data_frame, close_column_name) {
    # make sure the data frame is sorted by date
    data_frame <- data_frame[order(data_frame$date, decreasing = TRUE), ]
    data_frame$dailyreturns <- c(-diff(log(data_frame[, close_column_name])), NA)

    return(data_frame)
}
# TODO auch diskrete rendite berechnen

# get value at risk
# TODO is this correct?
get_value_at_risk <- function(data_frame, returns_column_name, alpha) {
    # sort returns by size
    data_frame_sorted <- data_frame[order(data_frame[, returns_column_name], decreasing = TRUE), ]
    
    value_at_risk <- quantile(data_frame_sorted[, returns_column_name], alpha)

    return(value_at_risk)
}