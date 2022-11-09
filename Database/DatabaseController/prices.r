### THIS FILE CONTAINS ALL PRICE SPECIFIC DATABASE FUNCTIONS

source("./Database/DatabaseController/common.r")

insert_as_price <- function(data_frame) {
  insert_data(data_frame, "t_prices")
}

# GET PRICES FROM DATABASE
get_prices <- function(start_date, end_date, isin) {
  query <- sprintf(paste(
    "SELECT * FROM t_prices",
    "WHERE isin = '%s'",
    "AND date >= '%s'",
    "AND date <= '%s'"),
    isin, start_date, end_date)
  prices <- dbGetQuery(CONNECTION, query)

  return(prices)
}

count_prices <- function(isin) {
  query <- sprintf(paste(
    "SELECT COUNT(*)",
    "FROM t_prices",
    "WHERE isin = '%s'"),
    isin)
  count <- dbGetQuery(CONNECTION, query)

  #take first and cast to int
  return(as.integer(count[[1]][[1]]))
}

delete_prices <- function(isin) {
  query <- sprintf(paste(
    "DELETE FROM t_prices",
    "WHERE isin = '%s'"),
    isin)
  res <- dbSendStatement(CONNECTION, query)
  cat(sprintf("Deleted %i rows", dbGetRowsAffected(res)))
  dbClearResult(res)
}
