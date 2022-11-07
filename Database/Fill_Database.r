library(dotenv)
library(DBI)
library(RPostgres)

# load .env file
load_dot_env(".env")

# GLOBAL VARIABLES
dbPassword <- Sys.getenv("DB_PASSWORD")

# FUNCTIONS

# Gets db connection instance
get_db_connection <- function() {
  con <- dbConnect(RPostgres::Postgres(),
                      host = "riskmanagement.jjungbluth.de",
                      dbname = "riskmanagement",
                      user = "riskmanagement",
                      password = dbPassword,
                      port = 5432)
  return(con)
}

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

# Inserts data_frame into database
insert_data <- function(data_frame, table_name, connection) {
  cat(sprintf("Inserting %i rows into %s", nrow(data_frame), table_name))
  dbWriteTable(connection, table_name, data_frame, append = TRUE)
}

# Inserts prices into database
insert_as_price <- function(data_frame, connection) {
  insert_data(data_frame, "t_prices", connection)
}

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


head(deutsche_bank_data)

# connect to database
con <- get_db_connection()

# insert data
# do not run multiple times without deleting data first
insert_as_price(deutsche_bank_data, con)
insert_as_price(mercedes_benz_group_data, con)




