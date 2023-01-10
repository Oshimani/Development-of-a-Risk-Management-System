# LOCAL IMPORTS
source("./Database/DatabaseController/common.r") # ISINS are here

source("./Database/DataPreparation.r")
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/common.r")


prepare_data <- function(isin, csv_path) {
  # read csv data
  data <- read.csv2(csv_path, sep = ";", header = TRUE)

  # clean data
  data <- clean_data_frame(data)

  # add daily returns
  data <- get_continuous_daily_returns(data, "close")

  # add stock identifyer
  data <- add_stock_identifyer(data, isin)

  # preview data
  print(isin)
  tail(data)

  return(data)
}

### ----------- MAIN SCRIPT ------------------------------------------------

# create tuples containing isin and csv
stock_data <- data.frame(
  db <- c(DEUTSCHE_BANK_ISIN, "./data/dbk.csv"),
  mbg <- c(MERCEDES_BENZ_GROUP_ISIN, "./data/mbg.csv")
)

for (stock in stock_data) {
  # prepare data
  data <- prepare_data(stock[1], stock[2])

  # database connection is being established in DatabaseController/common.r

  # delete existing prices
  delete_prices(stock[1])

  # insert data into database
  insert_as_price(data)

  # count data
  print(sprintf("Count of %s: %i", stock[1], count_prices(stock[2])))
}
