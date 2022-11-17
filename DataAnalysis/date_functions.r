# subtract days from date
subtract_days <- function(date, days) {
    date <- as.Date(date)
    date <- date - days
    return(date)
}

# get dates from start_date to end_date
get_dates <- function(start_date, end_date) {
    dates <- seq(as.Date(start_date), as.Date(end_date), by = "day")
    # format as dataframe
    dates <- data.frame(date = dates)

    return(dates)
}

# get subset of dataframe for defined period
get_data_frame_subset <- function(data_frame,
                                  start_date,
                                  end_date,
                                  date_column_name = "date") {
    subset <- data_frame[
        data_frame[, date_column_name] >= start_date &
            data_frame[, date_column_name] <= end_date,
    ]

    return(subset)
}
