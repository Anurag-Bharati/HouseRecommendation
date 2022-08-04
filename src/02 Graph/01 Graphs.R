# Visualization ----
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
  legend.background =  element_rect(fill = "grey7"),
)
  
# HOUSE PRICE ----
# Good article I Found https://www.statology.org/when-to-use-mean-vs-median/
HousePrices %>% group_by(Date, County) %>% 
  summarise(`Average Cost` = median(Price)) %>% 
  mutate(hma=`Average Cost`>175000 & County=="MERSEYSIDE") %>% 
  mutate(hmc=`Average Cost`>200000 & County!="MERSEYSIDE") %>% 
  ggplot(mapping = aes(x=Date, y=`Average Cost`, color=County)) +
  geom_line(size=1, alpha=0.8, arrow=arrow(type = "closed",length = unit(0.2, "cm")),lineend = "round") +
  geom_point(aes(size=if_else(hma|hmc,I(4),I(-10)),shape = I(1),stroke=I(.8),alpha=I(0.8)),color="#fa7a43")+
  dark_mode(theme_fivethirtyeight()) + scale_y_continuous(labels = euro) + 
  labs(title="Median house price vs year",
       subtitle = "Median prices of house from 2019 to the end of 2021") +
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo")+
  myTheme

HousePrices %>%
  group_by(Date,District, County) %>% 
  summarise(`Average Cost` = mean(Price)) %>%
  ggplot(mapping = aes(x=Date, y=`Average Cost`, color=County)) +
  geom_line(size=1, alpha=0.8, arrow=arrow(type = "closed",length = unit(0.2, "cm")),lineend = "round") +
  dark_mode(theme_fivethirtyeight()) + scale_y_log10(labels = euro) + 
  facet_wrap(~ District,nrow = 3) +
  labs(title="Mean house price vs year by district",
       subtitle = "Mean prices of house from 2019 to end of 2021",
       caption = "*price in logarithmic scale") + 
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme

HousePrices %>%
  filter(County=="MERSEYSIDE") %>% 
  group_by(Town,District, County) %>%
  summarise(Price = mean(Price, na.rm=T)) %>%
  ggplot(mapping = aes(x=District,y=Price,fill=County)) +
  geom_boxplot(outlier.colour = "#fa7a43") +
  scale_y_continuous(labels = euro) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Town averaged House price by District",
       subtitle = "in Merseyside") +
  scale_fill_viridis_d(begin = 0.5,end=0.8, option = "G") +
  myTheme

HousePrices %>%
  filter(!County=="MERSEYSIDE") %>% 
  group_by(Town,District, County) %>%
  summarise(Price = mean(Price, na.rm=T)) %>%
  ggplot(mapping = aes(x=District,y=Price,fill=County)) +
  geom_boxplot(outlier.colour = "#fa7a43") + 
  coord_cartesian(ylim =  c(40000, 2400000)) +
  scale_y_log10(labels = euro) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Town averaged House price by District",
       subtitle = "in Greater Manchester",
       caption = "*price in logarithmic scale \n*y-scale capped to low:40000, high:2000000") +
  scale_fill_viridis_d(begin = 0.5,end=0.8, option = "A") +
  myTheme

HousePrices %>% filter(County=="MERSEYSIDE") %>% 
  group_by(District, Town) %>% 
  summarize(mean_price = mean(Price)) %>% 
  ggplot(aes(x = District,  y = mean_price)) +
  geom_col(aes(fill = Town)) + #,position = "dodge"
  scale_y_continuous(labels = euro) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title = "Mean Housing Prices by District",
       subtitle = "in the Merseyside") +
  scale_fill_viridis_d(begin = 0.4,end=1, option = "D") +
  myTheme

HousePrices %>% filter(!County=="MERSEYSIDE") %>% 
  group_by(District, Town) %>% 
  summarize(Mean = mean(Price)) %>% 
  ggplot(aes(x = District,  y = Mean)) +
  geom_col(aes(fill = Town)) +
  scale_y_continuous(labels = euro) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title = "Mean Housing Prices by District",
       subtitle = "in the Greater Manchester") +
  scale_fill_viridis_d(begin = 0.4,end=1, option = "A") +
  myTheme

# BANDWIDTH ----

Bandwidth %>%
  select(Postcode, AvgDownload, AvgUpload) %>%
  inner_join(HousePrices, by="Postcode") %>%
  filter(County=="MERSEYSIDE") %>%
  group_by(District, Town) %>%
  summarise(Mean = mean(AvgDownload, na.rm=T)) %>%
  ggplot(aes(x = District,  y = Mean)) +
  geom_bar(stat = "identity", aes(fill = Town)) +
  scale_y_continuous(labels = function(x) scales::comma(x, suffix = ' Mbps')) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Average download speed by district",
       subtitle = "in the Merseyside",
       caption = "Mbps: Megabits per second") +
  scale_fill_viridis_d(begin = 0.4,end=1, option = "D") +
  myTheme

Bandwidth %>%
  select(Postcode, AvgDownload, AvgUpload) %>%
  inner_join(HousePrices, by="Postcode") %>%
  filter(!County=="MERSEYSIDE") %>%
  group_by(District, Town) %>%
  summarise(Mean = mean(AvgDownload, na.rm=T)) %>%
  ggplot(aes(x = District,  y = Mean)) +
  geom_bar(stat = "identity", aes(fill = Town,)) +
  scale_y_continuous(labels = function(x) scales::comma(x, suffix = ' Mbps')) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Average download speed by district",
       subtitle = "in the Greater Manchester",
       caption = "Mbps: Megabits per second") +
  scale_fill_viridis_d(begin = 0.4,end=1, option = "A") +
  myTheme

Bandwidth %>%
  select(Postcode, AvgDownload, AvgUpload) %>%
  inner_join(HousePrices, by="Postcode") %>%
  group_by(District, County) %>%
  summarise(Down = mean(AvgDownload, na.rm=T)) %>%
  arrange(County) %>%
  ggplot(mapping = aes(x=County,y=Down,fill=County)) +
  geom_boxplot() +  scale_y_continuous(labels = function(x) scales::comma(x, suffix = '  \nMbps')) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Average download speed by district",
       subtitle = "in Greater manchester and merseyside",
       caption = "Mbps: Megabits per second") +
  scale_color_viridis_d(begin = 0.25,end=0.45, option = "inferno") +
  myTheme

# CRIME ----

Crime %>% filter(Type=="Drugs" & Department!="Merseyside Police") %>%
  ggplot(aes(x=Type, y= Date, fill=Type))+
  geom_boxplot(outlier.colour = "#fa7a43") +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Box plot of Drug offence in mid 2019",
       subtitle = "in Greater Manchester") +
  scale_fill_viridis_d(begin = 0.5,end=0.8, option = "A") +
  myTheme

Crime %>% filter(Type=="Drugs" ) %>%
  group_by(Date, Department) %>%
  ggplot(aes(x=Type, y= Date, fill=Department))+
  geom_boxplot(outlier.colour = "#fa7a43") +
  dark_mode(theme_fivethirtyeight()) + coord_flip()+
  labs(title="Box plot of Drug offence in 2019-2022(mid)",
       subtitle = "in Greater Manchester & Merseyside") +
  scale_fill_viridis_d(begin = 0.5,end=0.8, option = "A") +
  myTheme

# Line graph
CrimeTypeCount %>%
  group_by(Date,District, Ward) %>% filter(County == "Merseyside") %>% filter(District == "Liverpool") %>%
  summarise(`Crime Count` = sum(Drugs, na.rm=T)) %>% filter(`Crime Count`>1) %>%
  ggplot(mapping = aes(x=Date, y=`Crime Count`, color=Ward)) +
  geom_line(size=1, alpha=0.8, arrow=arrow(type = "closed",length = unit(0.2, "cm")),lineend = "round", show.legend = F) +
  dark_mode(theme_fivethirtyeight()) + scale_y_log10() +
  facet_wrap(~ Ward) +
  labs(title="No. of Drugs crime cases from 2019-2022(mid)",
       subtitle = "in Liverpool, Merseyside",
       caption = "*count in logarithmic scale") +
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme

CrimeTypeCount %>% filter(str_to_lower(County)=="merseyside") %>%
  select(-LSOA, -LLSOA, -Ward, -PCD, -County) %>%
  rename_with(~ str_c('c', 3:16), 3:16) %>% 
  group_by(Date,District) %>%
  summarise_all(sum) %>% rowwise() %>% 
  transmute(total = sum(c(c3,c4,c5,c6,c7,c8,c9,c10, c11, c12, c13,c14,c15,c16)),District) %>% ungroup() %>% 
  ggplot(mapping = aes(x=Date, y=total, color=District)) +
  geom_line(size=1, alpha=0.8, arrow=arrow(type = "closed",length = unit(0.2, "cm")),lineend = "round", show.legend = F) +
  dark_mode(theme_fivethirtyeight()) +
  facet_wrap(~ District) +
  labs(title="No. of crime cases from 2019-2022(mid)",
       subtitle = "inside Merseyside County") +
  scale_color_viridis_d(begin = 0.4,end=1, option = "magma") +
  myTheme

CrimeTypeCount %>% filter(Ward %in% c("Prescot North","Prescot South","Wallasey")) %>%
  select(-LSOA, -LLSOA, -District, -PCD, -County ) %>%
  rename_with(~ str_c('c', 3:16), 3:16) %>%
  group_by(Date,Ward) %>%
  summarise_all(sum) %>% rowwise() %>%
  transmute(total = sum(c(c3,c4,c5,c6,c7,c8,c9,c10, c11, c12, c13,c14,c15,c16)),Ward) %>% ungroup() %>%
  ggplot(mapping = aes(x=Date, y=total, color=Ward)) +
  geom_line(size=1.5, alpha=0.8, arrow=arrow(type = "closed",length = unit(0.2, "cm")),lineend = "round", show.legend = T) +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="No. of crime cases from 2019-2022(mid)",
       subtitle = "in Towns in Merseyside") +
  scale_color_viridis_d(begin = 0.4,end=1, option = "magma") +
  myTheme

CrimeTypeCount %>% select(Robbery, District) %>%
  filter(District %in% c("Manchester", "Liverpool", "Wirral","Sefton", "" )) %>%
  group_by(District) %>%
  summarise(Percentage = sum(Robbery, na.rm=T)/sum(.$Robbery, na.rm = T), count=sum(Robbery)) %>%
  arrange(Percentage) %>% ggplot(mapping = aes(x="", y=Percentage, fill=District)) +
  geom_col() + coord_polar("y", start=0, clip="off") +
  geom_text(aes(label=paste0(round(Percentage*100), "%", " (", count, ") cases")),position = position_stack(vjust = 0.5))+
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Robbery in 2019-2022(mid)",
       subtitle = "in Manchester, Liverpool, Wirral, Sefton and St. Helens \n *100% = 3522 cases") +
  scale_fill_viridis_d(begin =0.2,end=0.5,option = "A") +
  myTheme

CrimeTypeCount %>% mutate(Date=year(Date)) %>%  filter(Date == 2021) %>% select(Robbery,District) %>%
  group_by(District) %>%
  summarise(Percentage = sum(Robbery, na.rm=T)/sum(.$Robbery, na.rm = T), count=sum(Robbery)) %>% filter(Percentage>0) %>%
  arrange(Percentage) %>% ggplot(mapping = aes(x="", y=Percentage, fill=District)) +
  geom_col() + coord_polar("y", start=0, clip="off") +
  geom_text(aes(label=paste0(round(Percentage*100), "%", " (", count, ") cases")),position = position_stack(vjust = 0.5))+
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Robbery in 2021 by District",
       subtitle = "*100% = 1212 cases") +
  scale_fill_viridis_d(begin =0.2,end=0.5,option = "A") +
  myTheme

# SCHOOL ----

# BOX PLOT
School %>% filter(TOWN %in% "Manchester") %>%
  group_by(Year, SCHNAME,TOWN) %>%
  summarise(Score = mean(Score)) %>%
  ggplot(mapping=aes(y=SCHNAME, x=Score, fill=SCHNAME)) +
  geom_boxplot(outlier.colour = "#fa7a43", show.legend = F) +
  scale_x_continuous(breaks = seq(0,100,10))+
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Box plot of Average School Score in Manchester",
       subtitle = "from year 2016 - 2019") +
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme

School %>% filter(TOWN %in% "Liverpool") %>%
  group_by(Year, SCHNAME,TOWN) %>%
  summarise(Score = mean(Score)) %>% ungroup() %>%
  ggplot(mapping=aes(y=SCHNAME, x=Score, fill=SCHNAME)) +
  geom_boxplot(outlier.colour = "#fa7a43", show.legend = F) +
  scale_x_continuous(breaks = seq(0,100,10))+
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Box plot of Average School Score in Liverpool",
       subtitle = "from year 2016 - 2019") +
  scale_color_viridis_d(begin = 0.4,end=0.6, option = "turbo") +
  myTheme

# LINE GRAPH
School %>%
  group_by(Year,District, County) %>%
  summarise(Score = mean(Score)) %>%
  ggplot(mapping = aes(x=Year, y=Score, color=County)) + facet_wrap(~District, nrow=3)+
  geom_line(size=1, alpha=0.8, arrow=arrow(type = "closed",length = unit(0.2, "cm")),lineend = "round") +
  dark_mode(theme_fivethirtyeight()) +
  scale_y_continuous()+
  labs(title="Mean Attainment 8 Score vs Year by District",
       subtitle = "from 2016 to 2019") +
  scale_color_viridis_d(begin = 0.3,end=0.7, option = "turbo") +
  myTheme

School %>% filter(District %in% c("Liverpool", "Manchester")) %>% 
  group_by(Year,TOWN) %>%
  summarise(Score = mean(Score)) %>%
  ggplot(mapping = aes(x=Year, y=Score, color=TOWN)) + facet_wrap(~TOWN, nrow=1)+
  geom_line(size=1, alpha=0.8, arrow=arrow(type = "closed",length = unit(0.2, "cm")),lineend = "round") +
  dark_mode(theme_fivethirtyeight()) +
  scale_y_continuous()+
  labs(title="Mean Acedemic Attainment Score vs Year",
       subtitle = "from 2016 to 2019") +
  scale_color_viridis_d(begin = 0.3,end=0.7, option = "turbo") +
  myTheme
