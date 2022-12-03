library(dplyr)
library(ggplot2)

# LOCAL IMPORTS
source("./Database/DatabaseController/prices.r")
source("./DataAnalysis/common.r")
source("./DataAnalysis/date_functions.r")
source("./DataAnalysis/value_at_risk.r")

# observation period
end_date <- as.Date("2022-01-01")
chosen_date <- as.Date("2021-10-30")
duration <- 20
start_date <- subtract_days(chosen_date, duration)


alpha <- 0.01
var_observation_period <- 20

# close_column_name = the name of the column containing the closing price
# chosen_date <- as.Date("2021-10-30")
# calculate value at risk for 20 days

#get_value_at_risk_for_target_date(deutsche_bank_data,chosen_date, var_observation_period, alpha = alpha)
#get_dates(start_date, chosen_date)
get_value_at_risk_for_20_days<- function(data_frame,
                                               chosen_date,
                                               observation_period,
                                               date_column_name = "date",
                                               returns_column_name = "dailyreturns",
                                               alpha){
  start_date <- subtract_days(chosen_date, observation_period + 1)
  end_date <- subtract_days(chosen_date, 1)
  
  # get subset of dataframe to calculate value at risk
  subset <- get_data_frame_subset(data_frame, start_date, end_date, "date")
  var_date <- get_value_at_risk_for_target_date(deutsche_bank_data,chosen_date, var_observation_period, alpha = alpha)
  var_20 <- var_date * sqrt(20)
  print(paste("var_20:", var_20))
  return(var_20)
}
get_value_at_risk_for_20_days(deutsche_bank_data,chosen_date, var_observation_period, alpha = alpha)


deutsche_bank_data$var_20 <- apply(deutsche_bank_data, 1, function(x) {
  get_value_at_risk_for_20_days(deutsche_bank_data, getElement(x, "date"), var_observation_period, alpha = alpha)
})


# get all overshoots
overshoots <- deutsche_bank_data[deutsche_bank_data$dailyreturns < deutsche_bank_data$var_20, ]
print(overshoots)

# plot returns together with value at risk
ggplot(deutsche_bank_data, aes(x = date)) +
  geom_point(aes(y = dailyreturns), color = "blue", size = 3) +
  geom_line(aes(y = var), color = "red", size = 1) +
  labs(
    title = "Value at Risk for Deutsche Bank",
    x = "Date",
    y = "Returns"
  )



#Der VaR wird einmal für das Backtesting berechnet und einmal 
#für ein Limit (max. 20% Verlust in 20 Tagen), Für das Backtesting 
#wird ein 1-Tages VaR verwendet und für das Limit ein 20-Tages VaR. 
#Beides mal wird zunächst der 1-Tages VaR basierend auf 1-tages Renditen berechnet. 
#Anschließend wird der 20-Tages VaR mit der Wurzel(Zeit) Regel skaliert auf 20-Tage und mit den 20% vom NAV verglichen.

