if(!"tidyverse" %in% (.packages())){library(tidyverse)} else {print("Tidyverse has already been loaded.")}
if(!"scales" %in% (.packages())){library(scales)} else {print("Scale has already been loaded.")}
if(!"lubridate" %in% (.packages())){library(lubridate)} else {print("Lubridate has already been loaded.")}
if(!"ggthemes" %in% (.packages())){library(ggthemes)} else {print("Ggtheme has already been loaded.")}
if(!"ragg" %in% (.packages())){library(ragg)} else {print("Ragg has already been loaded.")}

crime_merseyside <- list.files(path="./raw/crime dataset 19-21/merseyside/", full.names = TRUE) %>% 
  read_csv(.) %>% 
  bind_rows

crime_manchester <- list.files(path="./raw/crime dataset 19-21/manchester/", full.names = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows

# Overview of missing item in % (col wise)
sapply(crime_manchester, function(x) sum(x=="" | is.na(x)))/nrow(crime_manchester) * 100
# Outcome: In variable Crime-ID and Last outcome category, ~17.268% of value is Missing 
# Similarly the var Context is missing 100% of its value so these variables are omitted
# Additionally Reported by and Fall Within is exactly same so its ought to be omitted too.

crime_manchester = crime_manchester %>% 
  select(-`Crime ID`, -Context, -`Reported by`, -`Last outcome category`)

# Overview of missing item in % (row wise)
missing_manchester <-  apply(crime_manchester, 1, function(x) sum(x==""| is.na(x))) / ncol(crime_manchester) * 100
head(missing_manchester[order(-missing_manchester)])
# Max missing data percentage is 0


# Overview of missing item in % (col wise)
sapply(crime_merseyside, function(x) sum(x=="" | is.na(x)))/nrow(crime_merseyside) * 100
# Outcome: In variable Crime-ID and Last outcome category, ~18.44% of value is Missing 
# Similarly the var Context is missing 100% of its value so these variables are omitted
# Additionally Reported by and Fall Within is exactly same so its ought to be omitted too.

crime_merseyside = crime_merseyside %>% 
  select(-`Crime ID`, -Context, -`Reported by`, -`Last outcome category`)

# Overview of missing item in % (row wise)
missing_merseyside <-  apply(crime_merseyside, 1, function(x) sum(x==""| is.na(x))) / ncol(crime_merseyside) * 100
head(missing_merseyside[order(-missing_merseyside)])
# Max missing data percentage is 0

Crime = crime_merseyside %>% 
  add_row(crime_manchester) %>% 
  distinct

geocodes <- read_csv('./raw/PCD_OA_LSOA_MSOA_LAD_MAY22_UK_LU.csv', show_col_types = FALSE)

crime.type <- Crime %>% 
  group_by(`Crime type`) %>% 
  summarise(n = n()) %>% 
  select(type=`Crime type`, count=n)

Crime %>% 
  select(`Crime type`) %>% 
  mutate(type = factor(`Crime type`)) %>% 
  ggplot(.,aes(y=type, fill=type)) + geom_bar() + coord_flip()



