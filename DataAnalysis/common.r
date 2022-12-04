### THIS FILE CONTAINS ALL COMMON MATHEMACICALLY FUNCTIONS

# calculate logarithmic daily returns
# close_column_name = the name of the column containing the closing price
# stetige/ kontinuierliche rendite
get_continuous_daily_returns <- function(data_frame, close_column_name="close") {
  # make sure the data frame is sorted by date
  data_frame <- data_frame[order(data_frame$date, decreasing = TRUE), ]
  data_frame$dailyreturns <- c(-diff(log(data_frame[, close_column_name])), NA)

  return(data_frame)
}

