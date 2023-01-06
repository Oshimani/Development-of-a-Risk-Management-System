# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./Database/DatabaseController/portfolios.r")
source("./Database/DatabaseController/vars.r")
source("./DataAnalysis/common.r")
source("./DataAnalysis/date_functions.r")
source("./DataAnalysis/value_at_risk.r")

# DAILY VAR CALCULATION ----------------------
# CONSTANTS
portfolios <- c(
    "Portfolio von Jannick",
    "Portfolio von Liwen",
    "Portfolio von Philipp",
    "Mercedes Benz",
    "Deutsche Bank",
    "Philipps Testportfolio"
)

alpha <- 0.01
var_observation_period <- 250
# target date
target_date <- as.Date("2022-11-07")

for (portfolio_name in portfolios) {
    # portfolio weights at target date (usually today)
    pf_weights <- get_portfolio_weights_at_target_date(portfolio_name, target_date)
    pf_weights$close <- NULL
    pf_weights$dailyreturns <- NULL
    pf_weights$value <- NULL
    pf_weights$amount <- NULL
    pf_weights$date <- NULL

    # manual weights input
    # pf_weights <- data.frame(
    #     isin = c("DE0005140008", "DE0007100000"),
    #     weight = c(0.7, 0.3)
    # )

    # get prices
    start_date <- subtract_days(target_date, var_observation_period)
    prices <- get_all_prices(start_date, target_date)

    df <- merge(prices, pf_weights, by = "isin")

    df_returns <- df %>%
        group_by(date) %>%
        summarise(
            dailyreturns = sum(dailyreturns * weight)
        ) %>%
        ungroup()
    df_returns <- data.frame(df_returns)

    # calculate var after 20 days 
    var_limit <- test_var_limit_by_holding_period(df_returns,
        target_date = target_date,
        observation_period = var_observation_period,
        date_column_name = "date",
        returns_column_name = "dailyreturns",
        alpha = alpha,
        holding_period = 20
    )
    print(var_limit)

    # convert named num into num
    var_as_num <- as.numeric(var_limit)
    var_as_num

    # save daily var
    save_var_limit_result(portfolio_name, var_as_num, target_date)
}
