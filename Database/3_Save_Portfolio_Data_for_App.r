# LOCAL IMPORTS
source("./Database/DatabaseController/common.r")
source("./Database/DatabaseController/portfolios.r")
source("./Database/DatabaseController/snapshots.r")

portfolios <- c(
    "Portfolio von Jannick",
    "Portfolio von Liwen",
    "Portfolio von Philipp",
    "Mercedes Benz",
    "Deutsche Bank",
    "Philipps Testportfolio"
)

for (portfolio_name in portfolios) {
    portfolio <- get_portfolio_as_timeseries(portfolio_name)

    save_portfolio_snapshot(portfolio_name, portfolio)
}
