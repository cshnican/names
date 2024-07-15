library(tidyverse)
library(ggplot2)

#source: https://www.avoindata.fi/data/fi/dataset/none/resource/957d19a5-b87a-4c4d-8595-49c22d9d3c58
finland <- read.csv('Data/sukunimitilasto-2023-08-01-dvv.csv')

us <- read.csv('Data/us_census_name_2010/surnames_appearing_more_than_100_times/Names_2010Census.csv') %>% 
  filter(name != 'ALL OTHER NAMES') %>%
  mutate(pctapi = ifelse(pctapi == '(S)', 0, as.numeric(pctapi)),
    count_nonapi = count * (1 -  pctapi/100)) %>%
  filter(count_nonapi !=0)

taiwan <- read.csv('Data/Chinese_name_data/taiwan_givenname.csv') %>% mutate(number = as.numeric(number))

populations <- tibble(
  society = c('finland', 'usa', 'taiwan'),
  year = c(2023, 2010, 2018),
  population_total = c(5545475, 309327143, 23726185) 
  # source: The World Bank + The United Nations
)

n=200
topn = 1:n

top50 <- tibble(
  rank = topn,
  finland = finland$Yhteensä[topn]/finland$Yhteensä[1],
  us = rev(sort(us$count_nonapi))[topn]/rev(sort(us$count_nonapi))[1],
  taiwan = taiwan$number[topn]/taiwan$number[1]
)

ggplot(top50 %>% pivot_longer(cols=-rank, names_to = 'society', values_to = "portion relative to the top"), 
       aes(x=rank, y=`portion relative to the top`, color=society, group=society)) +
  geom_point() +
  geom_line() +
  theme_bw(15) +
  theme(panel.grid = element_blank()) +
  ylim(0,1)

finland_entropy <- finland %>%
  #head(50) %>%
  mutate(society = 'Finland',
         total = sum(Yhteensä),
         freq = Yhteensä/total) %>%
  group_by(society) %>%
  summarize(entropy = sum(-freq*log2(freq)),
            total = sum(Yhteensä))

us_entropy <- us %>%
  #head(50) %>%
  mutate(society = 'USA',
         total = sum(count_nonapi),
         freq = count_nonapi/total) %>%
  group_by(society) %>%
  summarize(entropy = sum(-freq*log2(freq)),
            total = sum(count_nonapi))

taiwan_entropy <- taiwan %>%
  #head(n) %>%
  mutate(society = 'Taiwan',
         total = sum(number),
         freq = number/total) %>%
  group_by(society) %>%
  summarize(entropy = sum(-freq*log2(freq)),
            total = sum(number))


# prefix-names

taiwan_pn = read_csv('Data/Chinese_name_data/taiwan_2018.csv')

fins_pn = read_csv("Data/etunimitilasto-2023-08-01-dvv.csv")

pth <- 'Data/US_census_all'
us_states <- list.files(pth, "*.TXT")

read_files <- function(filename){
  d <- read.csv(paste0(pth, '/', filename), header = FALSE)
  colnames(d) = c('state', 'gender', 'year', 'name', 'frequency')
  return(d)
}

us_pn_post1910 <- lapply(us_states, read_files) %>% bind_rows() %>%
  filter(year > 1910)

taiwan_pn_entropy <- taiwan_pn %>%
  mutate(society = 'Taiwan',
         total = sum(Number),
         freq = Number/total) %>%
  group_by(society) %>%
  summarize(entropy_prefix = sum(-freq*log2(freq)),
          total_prefix = sum(Number))

finland_pn_entropy <- fins_pn %>%
  mutate(society='Finland',
         total=sum(Lukumäärä),
         freq = Lukumäärä/total) %>%
  group_by(society) %>%
  summarize(entropy_prefix = sum(-freq*log2(freq)),
            total_prefix = sum(Lukumäärä))

us_pn_entropy <- us_pn_post1910 %>%
  mutate(society='USA',
         total = sum(frequency)) %>%
  group_by(society, name) %>%
  summarize(number = sum(frequency)) %>% ungroup() %>%
  mutate(total = sum(number),
         freq = number/total) %>%
  group_by(society) %>%
  summarize(entropy_prefix = sum(-freq*log2(freq)),
            total_prefix = sum(number))


entropy = rbind(finland_entropy, us_entropy, taiwan_entropy) %>%
  left_join(populations, by='society') %>% 
  mutate(percent_population = total/population_total) %>% 
  left_join(us_pn_entropy %>% rbind(
    finland_pn_entropy, taiwan_pn_entropy 
  ), by='society') %>%
  mutate(percent_population_prefix = total_prefix/population_total,
         entropy_byname = entropy) %>%
  select(-entropy) %>%
  pivot_longer(cols=c(entropy_byname, entropy_prefix), names_to = 'entropy_type', values_to = 'entropy')

plot_prefix_name_vs_byname <- ggplot(entropy %>% 
         mutate(
           category = ifelse(entropy_type == 'entropy_prefix', 'prefix name entropy', 'byname entropy'),
           category =factor(category, levels=c('prefix name entropy', 'byname entropy'))), 
       aes(x=society, y=entropy, alpha = category)) +
  geom_col(position='dodge') +
  theme_classic(18) +
  scale_alpha_discrete(range = c(0.5, 1))

pdf('imgs/prefix_name_vs_byname.pdf')
plot_prefix_name_vs_byname
dev.off()

save(plot_prefix_name_vs_byname, file='Data/plots_from_byname_analysis.RData')

