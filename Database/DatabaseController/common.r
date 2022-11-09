### THIS FILE CONTAINS ALL NON DOMAIN SPECIFIC DATABASE FUNCTIONS

library(dotenv)
library(DBI)
library(RPostgres)

# load .env file
load_dot_env(".env")

# GET DB CONNECTION
get_connection <- function() {
  con <- dbConnect(RPostgres::Postgres(),
                      host = "riskmanagement.jjungbluth.de",
                      dbname = "riskmanagement",
                      user = "riskmanagement",
                      password = Sys.getenv("DB_PASSWORD"),
                      port = 5432)
  return(con)
}

CONNECTION <- get_connection()

# INSERT DATA FRAME INTO TABLE
insert_data <- function(data_frame, table_name) {
  cat(sprintf("Inserting %i rows into %s", nrow(data_frame), table_name))
  dbWriteTable(CONNECTION, table_name, data_frame, append = TRUE)
}