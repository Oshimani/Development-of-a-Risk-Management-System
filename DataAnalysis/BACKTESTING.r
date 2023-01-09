# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./Database/DatabaseController/portfolios.r")
source("./Database/DatabaseController/vars.r")
source("./DataAnalysis/common.r")
source("./DataAnalysis/date_functions.r")
source("./DataAnalysis/value_at_risk.r")

# BACKTESTING --------------------------------
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

for (portfolio_name in portfolios) {
    # get portfolio -> this contains data of the complete lifespan of the portfolio
    portfolio <- get_portfolio(portfolio_name)

    # backtesting -> calculate VaR where possible (250 days buffer required)
    portfolio_backtested <- calculate_var_for_data_frame(portfolio,
        observation_period = var_observation_period,
        alpha = alpha
    )

    # save backtesting results
    save_backtesting_results(portfolio_name, portfolio_backtested)

    # plot overshoots
    plot_overshoots(portfolio_backtested,
        returns_column_name = "dailyreturns",
        var_column_name = "var",
        title = paste("Overshoots for: \"", portfolio_name, "\"")
    )
}
