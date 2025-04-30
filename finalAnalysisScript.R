install.packages("zoo")
install.packages("data.table")
install.packages("tseries")
install.packages("ggplot2")
install.packages("arrow")
install.packages("forecast")
require(forecast)
require(arrow)
require(tseries)
require(zoo)
require(data.table)
require(ggplot2)


#----INITIALIZE & CLEAN----
df <- fread("C:/Users/Me/Desktop/JantzenResearch/Tam Dao/tam_dao_raw_data_294.csv")

#ensure date column exists
df[, date := as.Date(paste(YEAR, MONTH, "01", sep = "-"))]

#aggregate ABUNDANCE by GENUS_SPECIES and date
agg_data <- df[, .(ABUNDANCE = sum(ABUNDANCE)), by = .(date, GENUS_SPECIES)]

#reshape data to wide format (GENUS_SPECIES as columns)
wide_data <- dcast(agg_data, date ~ GENUS_SPECIES, value.var = "ABUNDANCE", 
                   fill = NA)

#generate a full sequence of monthly dates
full_dates <- seq(from = as.Date("2003-01-01"), to = as.Date("2013-12-12"), 
                  by = "month")

# Merge full date range with dataset to fill missing months
wide_data <- merge(data.table(date = full_dates), wide_data, by = "date", 
                   all.x = TRUE)

# Handle missing values (Choose one)
wide_data[is.na(wide_data)] <- 0

# Convert to zoo object (Now it is regular)
zoo_obj <- zoo(wide_data[, -1, with = FALSE], order.by = wide_data$date)

# Convert to ts (If fully regular, i.e., all months filled)
mts_obj <- ts(coredata(zoo_obj), start = c(2003, 1), frequency = 12)
mts_obj