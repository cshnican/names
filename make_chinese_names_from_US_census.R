library(tidyverse)
library(ggplot2)

# for now use pinyin spelling - new immigrants to USA, instead of kth-generation Chinese Americans
us_census_data <- read.csv('Data/us_census_name_2010/surnames_appearing_more_than_100_times/Names_2010Census.csv')
chinese_surname_list <- read.csv('Data/Chinese_name_data/chinese_surnames_400.csv') %>% select(pinyin) %>% distinct() %>% 
  pull(pinyin)


chinese_american_data <- us_census_data %>% filter(name %in% chinese_surname_list) 

write.csv(chinese_american_data, 'Data/Chinese (US 2010)/chinese_american_data.csv', row.names = FALSE)

ggplot(chinese_american_data, aes(x=reorder(name, -count), y=count)) +
  geom_point() +
  theme_bw(20) +
  theme(panel.grid = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())
