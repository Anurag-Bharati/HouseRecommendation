# READ DATA ----
bandwidth_2018 <- read_csv("./data/raw/broadband_speed_201805.csv", show_col_types = FALSE)

# CLEANING BANDWIDTH ----
Bandwidth = bandwidth_2018 %>% 
  select(.,postcode_space, AvgDownload=`Average download speed (Mbit/s)`, 
         AvgUpload=`Average upload speed (Mbit/s)`) %>%
  separate(postcode_space, into = c("PostcodePrefix", "PostcodeSuffix"), remove = F) %>% 
  filter(PostcodePrefix %in% RelevantPCD$`Postal District Code`) %>%
  select(Postcode = postcode_space, PostcodePrefix, AvgDownload, AvgUpload) %>% 
  na.omit() %>% distinct

# naCols(bandwidth_2018 %>% select(postcode_space, `Average download speed (Mbit/s)`))
# Outcome: Max missing values of Download Speed variable percentage is ~0.0722%
# Action: Omit NA

# naRows(bandwidth_2018 %>% select(postcode_space, `Average download speed (Mbit/s)`))
# Outcome: Some of the observation lacks 50% any of its attribute
# Action: Not needed

# Check for duplicates
# percentDuplicate(bandwidth_2018 %>% select(postcode_space, `Average download speed (Mbit/s)`))
# Outcome: No duplicates

write_csv(Bandwidth, "./data/clean/CleanBandwidth.csv")

# REMOVE TEMP ----
if (exists("bandwidth_2018")) {rm(bandwidth_2018, envir=.GlobalEnv)}