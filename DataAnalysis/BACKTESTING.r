# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./Database/DatabaseController/portfolios.r")
source("./DataAnalysis/common.r")
source("./DataAnalysis/date_functions.r")
source("./DataAnalysis/value_at_risk.r")

# BACKTESTING --------------------------------
# CONSTANTS
alpha <- 0.01
var_observation_period <- 250

# get portfolio -> this contains data of the complete lifespan of the portfolio
portfolio <- get_portfolio("Portfolio von Jannick")

# backtesting -> calculate VaR where possible (250 days buffer required)
portfolio_backtested <- calculate_var_for_data_frame(portfolio,
    observation_period = var_observation_period,
    alpha = alpha
)

# plot overshoots
plot_overshoots(portfolio_backtested, returns_column_name = "dailyreturns", var_column_name = "var", title = "Overshoots von \"Portfolio von Jannick\"")


