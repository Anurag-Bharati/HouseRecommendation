library(tidyverse)
library(scales)
library(ggfortify)
library(ggthemes)
library(ggdark)

CleanHousePrice <- read_csv("./data/clean/CleanHousePrices.csv", show_col_types = F)
CleanBandwidth <- read_csv("./data/clean/CleanBandwidth.csv", show_col_types = F)
CleanCrimeCount <- read_csv("./data/clean/CleanCrimeType.csv", show_col_types = F)
CleanSchool <- read_csv("./data/clean/CleanSchool.csv", show_col_types = F)
CleanFloodRisk<- read_csv("./data/clean/CleanFloodRisk.csv", show_col_types = F)

euro <- dollar_format(prefix = "\u20ac ", big.mark = ",")
# Custom Theme
myTheme <- theme(
  plot.title = element_text(hjust = 0.5),
  plot.margin = unit(c(0.5,1,0.5,1),"cm"), 
  plot.background = element_rect(fill = "grey10"),
  plot.caption = element_text(face = "bold.italic"),
  plot.subtitle = element_text(hjust = 0.5,margin =unit(c(0,0,0.5,0),"cm")),
  panel.spacing = unit(1, "cm"),
  panel.background = element_rect(fill = "grey12"),
  panel.grid.major = element_line(color = "grey20", size = I(0.5)),
  panel.grid.minor = element_line(color = "grey20", size = I(0.5)),
  strip.text = element_text(face = "bold"),
  legend.text = element_text(face = "bold"),
  strip.background = element_rect(fill = "grey7"),
  legend.background =  element_rect(fill = "grey7")
)


# HOUSE PRICE VS DOWNLOAD ----
# Bake
Bandwidth.HousePrice = CleanHousePrice %>%  
  group_by(PostcodePrefix, County) %>%
  summarise(Price=mean(Price)) %>%  
  inner_join(CleanBandwidth %>% 
               group_by(PostcodePrefix) %>%
               summarise(AvgDownload = mean(AvgDownload)) %>%
               ungroup(),by="PostcodePrefix") %>% na.omit
# Model
Bandwidth.HousePrice.LM = lm(Bandwidth.HousePrice, formula =  AvgDownload~Price)  

# Summary
summary(Bandwidth.HousePrice.LM)

# Visual
autoplot(Bandwidth.HousePrice.LM,label.colour = "#FF5733AA",
         smooth.colour = "red", colour = "#e1dd37BB",label.hjust = I(-0.5),
         ad.colour = "white", ad.size = I(0.5)) +
  dark_mode(theme_fivethirtyeight()) + myTheme + theme(axis.title = element_text())

# Plot
ggplot(Bandwidth.HousePrice,aes(x=Price,y=AvgDownload)) +
  geom_point(mapping = aes(color=County))+
  scale_x_log10(labels = euro)+
  scale_y_continuous(labels = scales::comma_format(suffix = " Mbps"))+
  dark_mode(theme_fivethirtyeight())+
  geom_smooth(formula = y~x, method = "lm", color="red")+
  labs(title="House Prices vs Download Speed",
       caption = "*price in logarithmic scale")+
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme

# HOUSE PRICE VS DRUG ----

Drug.HousePrice = CleanHousePrice %>%  
  group_by(PostcodePrefix, County) %>%
  summarise(Price=mean(Price)) %>%  
  inner_join(CleanCrimeCount %>% 
               group_by(PCD) %>%
               summarise(DrugCount = mean(Drugs)) %>%
               ungroup(),by=c("PostcodePrefix"="PCD")) %>% na.omit

# Model
Drug.HousePrice.LM = lm(Drug.HousePrice, formula = DrugCount~Price)  

# Summary
summary(Drug.HousePrice.LM)

# Visual
autoplot(Drug.HousePrice.LM,label.colour = "#FF5733AA",
         smooth.colour = "red", colour = "#e1dd37BB",label.hjust = I(-0.5),
         ad.colour = "white", ad.size = I(0.5)) +
  dark_mode(theme_fivethirtyeight()) + myTheme + theme(axis.title = element_text())

# Plot
ggplot(Drug.HousePrice,aes(x=Price,y=DrugCount)) +
  geom_point(mapping = aes(color=County))+
  scale_x_log10(labels = euro)+
  scale_y_continuous(labels = scales::comma_format(suffix = ""))+
  dark_mode(theme_fivethirtyeight())+
  geom_smooth(formula = y~x, method = "lm", color="red")+
  labs(title="House Prices vs Drug rate",
       caption = "*Price in logarithmic scale")+
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme


# SCHOOL SCORE VS DRUG  ----

Drug.School = CleanSchool %>% separate(Postcode, into = c("PostcodePrefix", "Suffix")) %>%  
  group_by(PostcodePrefix, County) %>%
  summarise(Score=mean(Score)) %>%  
  inner_join(CleanCrimeCount %>% 
               group_by(PCD) %>%
               summarise(DrugCount = mean(Drugs)) %>%
               ungroup(),by=c("PostcodePrefix"="PCD")) %>% na.omit

# Model
Drug.School.LM = lm(Drug.School, formula =  DrugCount~Score)  

# Summary
summary(Drug.School.LM)

# Visual
autoplot(Drug.School.LM,label.colour = "#FF5733AA",
         smooth.colour = "red", colour = "#e1dd37BB",label.hjust = I(-0.5),
         ad.colour = "white", ad.size = I(0.5)) +
  dark_mode(theme_fivethirtyeight()) + myTheme + theme(axis.title = element_text())

# Plot
ggplot(Drug.School,aes(x=Score,y=DrugCount)) +
  geom_point(mapping = aes(color=County))+
  scale_y_log10(labels = scales::comma_format(suffix = " count"))+
  scale_x_continuous(labels = scales::comma_format(suffix = " points"))+
  dark_mode(theme_fivethirtyeight())+
  geom_smooth(formula = y~x, method = "lm", color="red")+
  labs(title="School Score vs Drug count",
       caption = "*count in logarithmic scale")+
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme

# SCHOOL SCORE vs DOWNLOAD ----

Download.Score = CleanSchool %>% separate(Postcode, into = c("PostcodePrefix", "Suffix")) %>%  
  group_by(PostcodePrefix, County) %>%
  summarise(Score=mean(Score)) %>%  
  inner_join(CleanBandwidth %>% 
               group_by(PostcodePrefix) %>%
               summarise(AvgDownload = mean(AvgDownload)) %>%
               ungroup(),by="PostcodePrefix") %>% na.omit
# Model
Download.Score.LM = lm(Download.Score, formula = AvgDownload~Score)  

# Summary
summary(Download.Score.LM)

# Visual
autoplot(Download.Score.LM,label.colour = "#FF5733AA",
         smooth.colour = "red", colour = "#e1dd37BB",label.hjust = I(-0.5),
         ad.colour = "white", ad.size = I(0.5)) +
  dark_mode(theme_fivethirtyeight()) + myTheme + theme(axis.title = element_text())


# Plot
ggplot(Download.Score,aes(x=Score,y=AvgDownload)) +
  geom_point(mapping = aes(color=County))+
  scale_x_continuous(labels =  scales::comma_format(suffix = " Points"))+
  scale_y_continuous(labels = scales::comma_format(suffix = " Mbps"))+
  dark_mode(theme_fivethirtyeight())+
  geom_smooth(formula = y~x, method = "lm", color="red")+
  labs(title="Score vs Download Speed")+
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme


# SCHOOL SCORE vs HOUSE PRICE ----

Score.HousePrice = CleanSchool %>% separate(Postcode, into = c("PostcodePrefix", "Suffix")) %>%  
  group_by(PostcodePrefix, County) %>%
  summarise(Score=mean(Score)) %>%  
  inner_join(CleanHousePrice %>% 
               group_by(PostcodePrefix) %>%
               summarise(Price = mean(Price)) %>%
               ungroup(),by="PostcodePrefix") %>% na.omit
# Model
Score.HousePrice.LM = lm(Score.HousePrice, formula =  Score~Price) 


# Summary
summary(Score.HousePrice.LM)

# Visual
autoplot(Score.HousePrice.LM,label.colour = "#FF5733AA",
         smooth.colour = "red", colour = "#e1dd37BB",label.hjust = I(-0.5),
         ad.colour = "white", ad.size = I(0.5)) +
  dark_mode(theme_fivethirtyeight()) + myTheme + theme(axis.title = element_text())


# Plot
ggplot(Score.HousePrice,aes(x=Price,y=Score)) +
  geom_point(mapping = aes(color=County))+
  scale_y_continuous(labels =  scales::comma_format(suffix = " Points"))+
  scale_x_continuous(labels = euro)+
  dark_mode(theme_fivethirtyeight())+
  geom_smooth(formula = y~x, method = "lm", color="red")+
  labs(title="Score vs House Price")+
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme


# DOWNLOAD VS DRUG ----
# Bake
Drugs.Bandwidth = CleanBandwidth %>%  
  group_by(PostcodePrefix) %>%
  summarise(AvgDownload=mean(AvgDownload)) %>%  
  inner_join(CleanCrimeCount %>% 
               group_by(PCD, County) %>%
               summarise(DrugCount = sum(Drugs)) %>%
               ungroup(),by=c("PostcodePrefix"="PCD")) %>% na.omit
# Model
Drugs.Bandwidth.LM = lm(Drugs.Bandwidth, formula =  DrugCount~AvgDownload)  

# Summary
summary(Drugs.Bandwidth.LM)

# Visual
autoplot(Drugs.Bandwidth.LM,label.colour = "#FF5733AA",
         smooth.colour = "red", colour = "#e1dd37BB",label.hjust = I(-0.5),
         ad.colour = "white", ad.size = I(0.5)) +
  dark_mode(theme_fivethirtyeight()) + myTheme + theme(axis.title = element_text())

# Plot
ggplot(Drugs.Bandwidth,aes(x=AvgDownload,y=DrugCount)) +
  geom_point(mapping = aes(color=County))+
  scale_x_continuous(labels = scales::comma_format(suffix = " Mbps"))+
  scale_y_log10(labels = scales::comma_format(suffix = " Count"))+
  dark_mode(theme_fivethirtyeight())+
  geom_smooth(formula = y~x, method = "lm", color="red")+
  labs(title="Download Speed vs Drug Count",
       caption = "*count in logarithmic scale")+
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme