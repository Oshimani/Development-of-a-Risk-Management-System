source("./Database/DatabaseController/common.r")
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/date_functions.r")


# ##############################################
# CORE
# these functions are being shared by backtesting and var limit testing
private_get_var_results <- function(table_name, portfolio_name) {
    query <- sprintf(
        paste(
            "SELECT * FROM %s",
            "WHERE portfolio_id = (",
            "SELECT id FROM t_portfolios",
            "WHERE name = '%s'",
            ")"
        ),
        table_name, portfolio_name
    )
    results <- dbGetQuery(CONNECTION, query)
    return(results)
}

private_get_var_results_by_date_and_pf_name <- function(table_name, portfolio_name, date) {
    query <- sprintf(
        paste(
            "SELECT * FROM %s",
            "WHERE portfolio_id = (",
            "SELECT id FROM t_portfolios",
            "WHERE name = '%s'",
            ")",
            "AND date = '%s'"
        ),
        table_name, portfolio_name, date
    )
    results <- dbGetQuery(CONNECTION, query)
    return(results)
}

private_save_var_result <- function(table_name, portfolio_name, value, date) {
    # check if result already exists
    result <- private_get_var_results_by_date_and_pf_name(table_name, portfolio_name, date)

    query <- ""
    if (nrow(result) > 0) {
        # update existing backtesting result
        query <- sprintf(
            paste(
                "UPDATE %s",
                "SET value = %f",
                "WHERE portfolio_id = (",
                "SELECT id FROM t_portfolios",
                "WHERE name = '%s'",
                ")",
                "AND date = '%s'"
            ),
            table_name, value, portfolio_name, date
        )
    } else {
        # insert new backtesting result
        query <- sprintf(
            paste(
                "INSERT INTO %s (portfolio_id, value, date)",
                "VALUES (",
                "(SELECT id FROM t_portfolios WHERE name = '%s'), %f, '%s'",
                ")"
            ),
            table_name, portfolio_name, value, date
        )
    }
    res <- dbSendQuery(CONNECTION, query)
    dbClearResult(res)
}


# ##############################################
# BACKTESTING

get_backtesting_results <- function(portfolio_name) {
    res <- private_get_var_results("t_backtesting_results", portfolio_name)
    return(res)
}

get_backtesting_results_by_date_and_pf_name <- function(portfolio_name, date) {
    res <- private_get_var_results_by_date_and_pf_name("t_backtesting_results", portfolio_name, date)
    return(res)
}

# save backtesting var results
save_backtesting_result <- function(portfolio_name, value, dailyreturns, date) {
    # check if result already exists
    result <- private_get_var_results_by_date_and_pf_name("t_backtesting_results", portfolio_name, date)

    query <- ""
    if (nrow(result) > 0) {
        # update existing backtesting result
        query <- sprintf(
            paste(
                "UPDATE t_backtesting_results",
                "SET value = %f,",
                "dailyreturns = %f",
                "WHERE portfolio_id = (",
                "SELECT id FROM t_portfolios",
                "WHERE name = '%s'",
                ")",
                "AND date = '%s'"
            ),
            value, dailyreturns, portfolio_name, date
        )
    } else {
        # insert new backtesting result
        query <- sprintf(
            paste(
                "INSERT INTO t_backtesting_results (portfolio_id, value, dailyreturns, date)",
                "VALUES (",
                "(SELECT id FROM t_portfolios WHERE name = '%s'), %f, %f, '%s'",
                ")"
            ),
            portfolio_name, value, dailyreturns, date
        )
    }
    res <- dbSendQuery(CONNECTION, query)
    dbClearResult(res)
}


save_backtesting_results <- function(portfolio_name, data_frame) {
    for (i in seq_len(nrow(data_frame))) {
        result <- data_frame[i, ]
        print(paste("Saving backtesting result for: \"", portfolio_name, "\" on ", result$date, " with value: ", result$var))
        save_backtesting_result(portfolio_name, result$var, result$dailyreturns, result$date)
    }
    print("Done saving backtesting results")
}


# ##############################################
# VAR LIMIT TESTING

get_var_limit_results <- function(portfolio_name) {
    res <- private_get_var_results("t_var_limit_results", portfolio_name)
    return(res)
}

get_var_limit_results_by_date_and_pf_name <- function(portfolio_name, date) {
    res <- private_get_var_results_by_date_and_pf_name("t_var_limit_results", portfolio_name, date)
    return(res)
}

# save var limit results
save_var_limit_result <- function(portfolio_name, value, date) {
    private_save_var_result("t_var_limit_results", portfolio_name, value, date)
}

save_var_limit_results <- function(portfolio_name, data_frame) {
    for (i in seq_len(nrow(data_frame))) {
        result <- data_frame[i, ]
        print(paste("Saving var limit result for: \"", portfolio_name, "\" on ", result$date, " with value: ", result$var))
        save_var_limit_result(portfolio_name, result$var, result$date)
    }
    print("Done saving var limit results")
}
