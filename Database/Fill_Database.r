library(dotenv)
library(DBI)
library(RPostgres)

# LOCAL IMPORTS
source("./Database/DataPreparation.r")
source("./Database/DatabaseController/prices.r")


### ----------- MAIN SCRIPT ------------------------------------------------

# read csv data
deutsche_bank_data <- read.csv2("./data/dbk.csv", sep = ";", header = TRUE)
mercedes_benz_group_data <- read.csv2("./data/mbg.csv", sep = ";", header = TRUE)

# clean data
deutsche_bank_data <- clean_data_frame(deutsche_bank_data)
mercedes_benz_group_data <- clean_data_frame(mercedes_benz_group_data)

# add stock identifyer
deutsche_bank_data <- add_stock_identifyer(deutsche_bank_data, "DBK")
mercedes_benz_group_data <- add_stock_identifyer(mercedes_benz_group_data, "MBG")

# preview data
print("Deutsche Bank")
head(deutsche_bank_data)

print("Mercedes Benz Group")
head(mercedes_benz_group_data)


# database connection is being established in DatabaseController/common.r

# clear prices if already present to prevent messed up data
if (count_prices("DBK") > 0) {
  delete_prices("DBK")
}
insert_as_price(deutsche_bank_data)

if (count_prices("MBG") > 0) {
  delete_prices("MBG")
}
insert_as_price(mercedes_benz_group_data)

# count data
deutsche_bank_in_database_count <- count_prices("DBK")
cat(sprintf("Deutsche Bank in database: %i", deutsche_bank_in_database_count))

mercedes_benz_group_in_database_count <- count_prices("MBG")
cat(sprintf("Mercedes Benz Group in database: %i", mercedes_benz_group_in_database_count))


