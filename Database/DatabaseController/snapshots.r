source("./Database/DatabaseController/common.r")

get_portfolio_snapshot_component <- function(portfolio_name, isin, date) {
    query <- sprintf(
        paste(
            "SELECT * FROM t_snapshots",
            "WHERE portfolio_id = (",
            "SELECT id FROM t_portfolios",
            "WHERE name = '%s'",
            ")",
            "AND date = '%s'",
            "AND isin = '%s'"
        ),
        portfolio_name, date, isin
    )
    results <- dbGetQuery(CONNECTION, query)
    return(results)
}

save_portfolio_snapshot_component <- function(portfolio_name, isin, amount, date) {
    # check if result already exists
    result <- get_portfolio_snapshot_component(portfolio_name, isin, date)

    query <- ""
    if (nrow(result) > 0) {
        # update
        query <- sprintf(
            paste(
                "UPATE t_snapshots",
                "SET amount = %i",
                "WHERE portfolio_id = (",
                "SELECT id FROM t_portfolios",
                "WHERE name = '%s'",
                ")",
                "AND date = '%s'",
                "AND isin = '%s'"
            ),
            amount, portfolio_name, date, isin
        )
    } else {
        # insert
        query <- sprintf(
            paste(
                "INSERT INTO t_snapshots (portfolio_id, isin, amount, date)",
                "VALUES (",
                "(SELECT id FROM t_portfolios WHERE name = '%s'), '%s', %i, '%s'",
                ")"
            ),
            portfolio_name, isin, amount, date
        )
    }

    res <- dbSendQuery(CONNECTION, query)
    dbClearResult(res)
}

save_portfolio_snapshot <- function(portfolio_name, data_frame) {
    for (i in 1:nrow(data_frame)) {
        snapshot <- data_frame[i, ]
        print(paste("Saving snapshot component for: \"", portfolio_name, "\" on ", snapshot$date, " with isin: ", snapshot$isin, " and amount: ", snapshot$amount))
        save_portfolio_snapshot_component(
            portfolio_name,
            snapshot$isin,
            snapshot$amount,
            snapshot$date
        )
    }
}
