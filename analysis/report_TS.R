### Import Libraries

library('tidyverse')
library('reshape2')

### Import data

SGLT2_ethnicity_df <- read_csv(
    here::here("output/measures", "measure_SGLT2_ethnicity.csv"),
    col_types = cols(ethnicity = col_factor(), SGLT2s=col_integer(), Diabetes=col_integer(), value=col_double(), date=col_date())
)
SGLT2_region_df <- read_csv(
    here::here("output/measures", "measure_SGLT2_region.csv"),
    col_types = cols(region = col_factor(), SGLT2s=col_integer(), Diabetes=col_integer(), value=col_double(), date=col_date())
)

### Specify independent variable for plot loop

SGLT2_ethnicity_df <- mutate(SGLT2_ethnicity_df, indvar=ethnicity)
SGLT2_region_df <- mutate(SGLT2_region_df, indvar=region)

### Convert date format

SGLT2_ethnicity_df$date <- as.Date(SGLT2_ethnicity_df$date, "%d/%m/%Y")
SGLT2_region_df$date <- as.Date(SGLT2_region_df$date, "%d/%m/%Y")

###Rename ethnicity groupings

SGLT2_ethnicity_df$indvar <- as.character(SGLT2_ethnicity_df$indvar)
SGLT2_ethnicity_df['indvar'][SGLT2_ethnicity_df['indvar'] == '1'] <- 'White'
SGLT2_ethnicity_df['indvar'][SGLT2_ethnicity_df['indvar'] == '2'] <- 'Mixed'
SGLT2_ethnicity_df['indvar'][SGLT2_ethnicity_df['indvar'] == '3'] <- 'South Asian'
SGLT2_ethnicity_df['indvar'][SGLT2_ethnicity_df['indvar'] == '4'] <- 'Black'
SGLT2_ethnicity_df['indvar'][SGLT2_ethnicity_df['indvar'] == '5'] <- 'Other'

### Create vector of input data frame names

measures_input <- c("SGLT2_ethnicity_df", "SGLT2_region_df")

#### Function to plot time series graphs

TS_plotter <- function(data) {
ggplot(data, aes(x=date, y=value, colour=indvar, group=indvar)) +
  geom_line()
}

###Loop over multiple variables and print output
for(i in seq_along(measures_input)){
  print(TS_plotter(get(measures_input[i])))
  ggsave(
    plot=TS_plotter(get(measures_input[i])),
    filename=paste0("TS_",measures_input[i],".png"),
    path=here::here("output"))
}