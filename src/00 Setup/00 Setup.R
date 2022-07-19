# IMPORTS ----
if(!"tidyverse" %in% (.packages())){library(tidyverse,warn.conflicts = F)} else {print("Tidyverse has already been loaded.")}
if(!"lubridate" %in% (.packages())){library(lubridate,warn.conflicts = F)} else {print("Lubridate has already been loaded.")}

# DEPENDENCIES ----
# install.packages("tidyverse")
# install.packages("lubridate")

# CORE COMPONENT ----
MerseysidePCD <- read_csv("./data/mydata/PostalCodeToDistrictMerseyside.csv", show_col_types = F)
ManchesterPCD <- read_csv("./data/mydata/PostalCodeToDistrictManchester.csv", show_col_types = F)
RelevantPCD = ManchesterPCD %>%
  mutate(County="GREATER MANCHESTER") %>%
  add_row(MerseysidePCD%>%mutate(County="MERSEYSIDE")) %>%
  mutate(County = as.factor(County), District = as.factor(District))
rm(ManchesterPCD, MerseysidePCD)

# &`In Use?`=="Yes"
# https://www.doogal.co.uk/PostcodeCsvFields
MasterGeoCode = read_csv("./data/raw/NorthWestPostcodes.csv", show_col_types = F) %>%
  filter(County %in% c("Greater Manchester", "Merseyside")) %>%
  select(Postcode, County, District, Ward,`District Code`,`Ward Code`,
         `Lower layer super output area`,`LSOA Code`, `MSOA Code`,
         Population,`Nearest station`,`Distance to station`,
         `Postcode area`,`Postcode district`,`Average Income`,
         `Travel To Work Area`,`Distance to sea`)