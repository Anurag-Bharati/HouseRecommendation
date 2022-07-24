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

