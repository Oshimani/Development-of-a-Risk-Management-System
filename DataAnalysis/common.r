### THIS FILE CONTAINS ALL COMMON MATHEMACICALLY FUNCTIONS

# calculate logarithmic daily returns
# close_column_name = the name of the column containing the closing price
get_logarithmic_daily_returns <- function(data_frame, close_column_name) {
    # make sure the data frame is sorted by date
    data_frame <- data_frame[order(data_frame$date, decreasing = TRUE), ]
    data_frame$dailyreturns <- c(-diff(log(data_frame[, close_column_name])), NA)

    return(data_frame)
}
# get value at risk
# TODO is this correct?
get_value_at_risk <- function(data_frame, returns_column_name, confidence_level) {
    # sort returns by size
    data_frame_sorted <- data_frame[order(data_frame[, returns_column_name], decreasing = TRUE), ]

    # TODO is this the same as quantile() function?
    # TODO does this ignore the NA at the beginning of the data frame?
    # number of observations
    n <- nrow(data_frame_sorted)

    # calculate the index of the observation
    index <- floor(n * confidence_level)

    # get the value at risk
    value_at_risk <- data_frame_sorted[index, returns_column_name]

    return(value_at_risk)
}

get_statistisch_daily_returns <- function(data_frame, close_column_name) {
  # make sure the data frame is sorted by date
  data_frame <- data_frame[order(data_frame$date, decreasing = TRUE), ]
  data_frame$Returns <- c(diff(-data_frame$close),NA)
  data_frame$dailyreturns <- data_frame$Returns/data_frame$close
  #Reorder by return
  data_frame$sorted <- data_frame[order(data_frame$dailyreturns),]
  return(data_frame$sorted)
}
get_value_at_risk_statistisch <- function(data_frame, returns_column_name, confidence_level){
  VaR <- quantile (data_frame$dailyreturns,0.01)
  return(VaR)
}


