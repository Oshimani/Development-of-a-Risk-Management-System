# LOCAL IMPORTS
source("./Database/DatabaseController/common.r") # ISINS are here

source("./Database/DataPreparation.r")
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/common.r")

### ----------- MAIN SCRIPT ------------------------------------------------

# read csv data
deutsche_bank_data <- read.csv2("./data/dbk.csv", sep = ";", header = TRUE)
mercedes_benz_group_data <- read.csv2("./data/mbg.csv", sep = ";", header = TRUE)

# clean data
deutsche_bank_data <- clean_data_frame(deutsche_bank_data)
mercedes_benz_group_data <- clean_data_frame(mercedes_benz_group_data)

# add daily returns
deutsche_bank_data <- get_continuous_daily_returns(deutsche_bank_data, "close")
mercedes_benz_group_data <- get_continuous_daily_returns(mercedes_benz_group_data, "close")

# add stock identifyer
deutsche_bank_data <- add_stock_identifyer(deutsche_bank_data, DEUTSCHE_BANK_ISIN)
mercedes_benz_group_data <- add_stock_identifyer(mercedes_benz_group_data, MERCEDES_BENZ_GROUP_ISIN)

# preview data
print("Deutsche Bank")
tail(deutsche_bank_data)

print("Mercedes Benz Group")
tail(mercedes_benz_group_data)

# database connection is being established in DatabaseController/common.r

# clear prices if already present to prevent messed up data
if (count_prices(DEUTSCHE_BANK_ISIN) > 0) {
  delete_prices(DEUTSCHE_BANK_ISIN)
}
insert_as_price(deutsche_bank_data)

if (count_prices(MERCEDES_BENZ_GROUP_ISIN) > 0) {
  delete_prices(MERCEDES_BENZ_GROUP_ISIN)
}
insert_as_price(mercedes_benz_group_data)

# count data
deutsche_bank_in_database_count <- count_prices(DEUTSCHE_BANK_ISIN)
cat(sprintf("Deutsche Bank in database: %i", deutsche_bank_in_database_count))

mercedes_benz_group_in_database_count <- count_prices(MERCEDES_BENZ_GROUP_ISIN)
cat(sprintf("Mercedes Benz Group in database: %i", mercedes_benz_group_in_database_count))
