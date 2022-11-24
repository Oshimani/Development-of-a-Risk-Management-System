source("./Database/DatabaseController/common.r")

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

# fetching dates from prices table automatically excludes non-trading days
get_all_trading_dates_in_period <- function(start_date, end_date) {
    query <- sprintf(
        paste(
            "SELECT DISTINCT date",
            "FROM t_prices",
            "WHERE date >= '%s'",
            "AND date <= '%s'",
            "ORDER BY date ASC"
        ), start_date, end_date
    )
    dates <- dbGetQuery(CONNECTION, query)
    return(dates)
}

# get random date between start and end date
get_random_trading_dates <- function(start_date, end_date, n = 100) {
    # get only valid candidates (exclude weekends and holidays)
    date_candidates <- get_all_trading_dates_in_period(start_date, end_date)
    # print amount of candidates
    cat(sprintf("Found %i date candidates, taking %i samples", nrow(date_candidates), n))
    # pick at random
    random_dates <- data.frame(date = sample(date_candidates$date, n, replace = FALSE))

    # sort dates
    random_dates_sorted <- random_dates[order(random_dates$date, decreasing = FALSE), ]
    return(random_dates_sorted)
}

get_last_price_date <- function() {
    query <- sprintf(
        paste(
            "SELECT MAX(date) AS date",
            "FROM t_prices"
        )
    )
    date <- dbGetQuery(CONNECTION, query)
    return(as.Date(date[[1]][[1]]))
}
