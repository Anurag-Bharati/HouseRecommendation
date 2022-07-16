# IMPORTS ----

if(!"tidyverse" %in% (.packages())){library(tidyverse,warn.conflicts = F)} else {print("Tidyverse has already been loaded.")}
if(!"lubridate" %in% (.packages())){library(lubridate,warn.conflicts = F)} else {print("Lubridate has already been loaded.")}

# CORE COMPONENT ----
MerseysidePCD <- read_csv("./data/mydata/PostalCodeToDistrictMerseyside.csv", show_col_types = F)
ManchesterPCD <- read_csv("./data/mydata/PostalCodeToDistrictManchester.csv", show_col_types = F)
ReleventPCD = ManchesterPCD %>%
  mutate(County="GREATER MANCHESTER") %>%
  add_row(MerseysidePCD%>%mutate(County="MERSEYSIDE")) %>%
  mutate(County = as.factor(County), District = as.factor(District))
rm(ManchesterPCD, MerseysidePCD)
