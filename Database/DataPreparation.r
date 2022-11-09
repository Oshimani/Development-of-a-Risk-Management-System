# Removes unwanted columns and fits the data to the database model
clean_data_frame <- function(data_frame) {
  # remove unused columns from data_frame
  data_frame$Erster <- NULL
  data_frame$Hoch <- NULL
  data_frame$Tief <- NULL
  data_frame$Stuecke <- NULL
  data_frame$Volumen <- NULL

  # rename column Schlusskurs to value
  names(data_frame)[names(data_frame) == "Schlusskurs"] <- "value"
  names(data_frame)[names(data_frame) == "Datum"] <- "date"

  # convert column types
  data_frame$date <- as.Date(data_frame$date)
  data_frame$value <- as.numeric(data_frame$value)

  return(data_frame)
}

# Add stock identifyer to data_frame
add_stock_identifyer <- function(data_frame, stock_identifyer) {
  data_frame$isin <- stock_identifyer
  return(data_frame)
}