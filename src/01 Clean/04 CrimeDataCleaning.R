# READ DATA ----
geocodes <- read_csv('./data/raw/misc/PCD_OA_LSOA_MSOA_LAD_MAY22_UK_LU.csv', show_col_types = FALSE)
crime_merseyside <- list.files(path="./data/raw/crime dataset 19-21/merseyside/", full.names = TRUE) %>% 
  read_csv(.,show_col_types = FALSE) %>% bind_rows
crime_manchester <- list.files(path="./data/raw/crime dataset 19-21/manchester/", full.names = TRUE) %>% 
  read_csv(.,show_col_types = FALSE) %>% bind_rows

# CLEANING CRIME ----
# GOOD Artical https://ocsi.uk/2019/03/18/lsoas-leps-and-lookups-a-beginners-guide-to-statistical-geographies/
calculate_mode <- function(x) {
  uniqx <- unique(na.omit(x))
  uniqx[which.max(tabulate(match(x, uniqx)))]
}

MinGeoCode <- MasterGeoCode %>% 
  select(PCD=`Postcode district`, LLSOA=`Lower layer super output area`, LSOA=`LSOA Code`,
         District,County,Ward) %>% 
  mutate(PCD=as.factor(PCD), LLSOA=as.factor(LLSOA), District= as.factor(District),
         County= as.factor(County),Ward=as.factor(Ward)) %>% 
  group_by(LSOA) %>% 
  summarise(PCD=calculate_mode(PCD),
            LLSOA=calculate_mode(LLSOA),
            District=calculate_mode(District),
            County=calculate_mode(County),
            Ward=calculate_mode(Ward)) %>%
  ungroup() %>% distinct

Crime = crime_merseyside %>% 
  add_row(crime_manchester) %>% distinct() %>% 
  select(Date = Month, Department = `Falls within`, LSOA=`LSOA code`, Type=`Crime type` ) %>%
  mutate(Date=ym(Date), Type=as_factor(Type)) %>% ungroup

CrimeTypeCount = Crime %>%
  group_by(LSOA,Date) %>%
  pivot_wider(names_from = Type, values_from = Type, values_fn = length, values_fill = 0) %>%
  summarise_at(.vars = colnames(.[,4:17]), .funs = sum) %>%  left_join(MinGeoCode, by="LSOA") %>%
  select(PCD, LSOA, LLSOA, Date,County, District,Ward, everything()) %>%  distinct() %>% ungroup()

CountBeforeOmit <- sum(CrimeTypeCount[,8:(ncol(CrimeTypeCount))])
CrimeTypeCount <- CrimeTypeCount %>% na.omit

# Verify: To prove that the crime count is equally distributed across its type
CountBeforeOmit == nrow(Crime)

# Output : True
# A -> 561731 (ideal)

# naCols(Crime)
# Outcome: Max missing values per variable percentage is 0%
# Action: No action needed
# naRows(Crime)
# Outcome: Missing values per observation percentage is 0%
# Action:  No action needed

write_csv(Crime, "./data/clean/CleanCrime.csv")
write_csv(CrimeTypeCount, "./data/clean/CleanCrimeType.csv")

# REMOVE TEMP ----

if (exists("crime_manchester")) {rm(crime_manchester, envir=.GlobalEnv)}
if (exists("crime_merseyside")) {rm(crime_merseyside, envir=.GlobalEnv)}
if (exists("geocodes")) {rm(geocodes, envir=.GlobalEnv)}
