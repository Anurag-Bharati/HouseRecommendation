RobberyPercentage = CrimeTypeCount %>%
  select(Robbery, District) %>% 
  group_by(District) %>% 
  summarise(Percentage = sum(Robbery, na.rm=T)/sum(CrimeTypeCount$Robbery, na.rm = T)*100)

SumVerySmall <- tibble(District=c("Other"), Percentage = RobberyPercentage %>%
         select(Percentage) %>%
         filter(Percentage<2) %>% sum)

RobberyPercentage %>%
  add_row(SumVerySmall) %>%
  filter(Percentage>2) %>% 
  ggplot(mapping = aes(x="", y=Percentage, fill=District)) +
  geom_col() + coord_polar("y", start=0, clip="off") +
  geom_text(aes(label=paste0(round(Percentage), "%")),position = position_stack(vjust = 0.5))+
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Total Robbery cases in 2019-2022(mid)",
       subtitle = "by Town") +
  scale_fill_viridis_d(begin =0.2,end=0.5,option = "A") +
  myTheme

Crime %>% filter(Type=="Robbery") %>% 
  mutate(Date=str_split(Date,"-",3,TRUE)[,1]) %>% 
  group_by(Date) %>% 
  ggplot(data, mapping = aes(x="", y=Type, fill=Date)) +
  geom_col() + coord_polar("y", start=0, clip="off") +
  dark_mode(theme_fivethirtyeight()) +
  labs(title="Robbery in 2019-2022(mid)",
       subtitle = "in Merseyside") +
  scale_fill_viridis_d(begin = 0.5,end=0.8, option = "D") +
  myTheme


# mutate(Date=str_split(Date,"-",3,TRUE)[,1]) %>% 