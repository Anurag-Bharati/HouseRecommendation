# READ DATA ----
house_price_2021 <- read_csv("./data/raw/pp-2021.csv", col_names = FALSE, show_col_types = FALSE)
house_price_2020 <- read_csv("./data/raw/pp-2020.csv", col_names = FALSE, show_col_types = FALSE)
house_price_2019 <- read_csv("./data/raw/pp-2019.csv", col_names = FALSE, show_col_types = FALSE)

# Check for duplicates
percentDuplicate(house_price_2019 %>% select(-X1))
percentDuplicate(house_price_2020 %>% select(-X1))
percentDuplicate(house_price_2021 %>% select(-X1))
# Outcome: ~0.083%, ~0.088%. ~0.066% of observation are duplicate
# Action: Remove duplicates

# CLEANING HOUSE PRICES ----
HousePrices = house_price_2021 %>%
  add_row(house_price_2020) %>%
  add_row(house_price_2019) %>% 
  select(X2,X3,X4,X12,X13,X14) %>%
  set_names(c("Price", "Date","Postcode", "Town", "District", "County")) %>%
  filter(County %in% c("GREATER MANCHESTER", "MERSEYSIDE")) %>% 
  mutate(PostcodePrefix = str_split(Postcode," ",2,TRUE)[,1]) %>% 
  filter(PostcodePrefix %in% RelevantPCD$`Postal District Code`) %>%
  mutate(County = as.factor(County),
         District = as.factor(str_to_title(District)),
         Town=as.factor(str_to_title(Town)), 
         Date = paste(year(Date),month(Date), sep = "-")) %>%
  mutate(Date = ym(Date)) %>% distinct

Town = HousePrices %>% 
  select(PostcodePrefix, Town, District, County) %>% 
  group_by(PostcodePrefix, Town, District, County) %>% summarise()

naCols(HousePrices)
# Outcome: In variable Postcode, ~0.226% of value is N/A 
# Action: Removing N/A value in Variable Postcode
HousePrices = HousePrices %>% filter(Postcode == "" | Postcode != is.na(Postcode))

naRows(HousePrices)
# Outcome: Max missing values per observation percentage is 9.09%
# Action: Since the missing % ain't no significant, we shall skip :)

write_csv(HousePrices, "./data/clean/CleanHousePrices.csv")
# write_csv(Town, "./data/clean/CleanTown.csv")

# REMOVE TEMP ----
if (exists("house_price_2021")) {rm(house_price_2021, envir=.GlobalEnv)}
if (exists("house_price_2020")) {rm(house_price_2020, envir=.GlobalEnv)}
if (exists("house_price_2019")) {rm(house_price_2019, envir=.GlobalEnv)}
