library(tidyverse)
library(ggplot2)


# bynames
#source: https://www.avoindata.fi/data/fi/dataset/none/resource/957d19a5-b87a-4c4d-8595-49c22d9d3c58
finland <- read.csv('Data/sukunimitilasto-2023-08-01-dvv.csv')

us <- read.csv('Data/us_census_name_2010/surnames_appearing_more_than_100_times/Names_2010Census.csv') %>% 
  filter(name != 'ALL OTHER NAMES') %>%
  mutate(pctapi = ifelse(pctapi == '(S)', 0, as.numeric(pctapi)),
    count_nonapi = count * (1 -  pctapi/100)) %>%
  filter(count_nonapi !=0)

taiwan <- read.csv('Data/Chinese_name_data/taiwan_givenname.csv') %>% mutate(number = as.numeric(number))

populations <- tibble(
  society = c('Finland', 'USA', 'Taiwan'),
  year = c(2023, 2010, 2018),
  population_total = c(5583911, 308745538, 23659305) 
  # source: The World Bank + The United Nations
)


finland_entropy <- finland %>%
  mutate(society = 'Finland',
         total = sum(Yhteensä),
         freq = Yhteensä/total) %>%
  group_by(society) %>%
  summarize(entropy_byname = sum(-freq*log2(freq)),
            total_byname = sum(Yhteensä))

us_entropy <- us %>%
  mutate(society = 'USA',
         total = sum(count_nonapi),
         freq = count_nonapi/total) %>%
  group_by(society) %>%
  summarize(entropy_byname = sum(-freq*log2(freq)),
            total_byname = sum(count_nonapi))

taiwan_entropy <- taiwan %>%
  mutate(society = 'Taiwan',
         total = sum(number),
         freq = number/total) %>%
  group_by(society) %>%
  summarize(entropy_byname = sum(-freq*log2(freq)),
            total_byname = sum(number))


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

us_pn_post1930 <- lapply(us_states, read_files) %>% bind_rows() %>%
  filter(year > 1930)

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

us_pn_entropy <- us_pn_post1930 %>%
  mutate(society='USA',
         total = sum(frequency)) %>%
  group_by(society, name) %>%
  summarize(number = sum(frequency)) %>% ungroup() %>%
  mutate(total = sum(number),
         freq = number/total) %>%
  group_by(society) %>%
  summarize(entropy_prefix = sum(-freq*log2(freq)),
            total_prefix = sum(number))

# combining them together

entropy = rbind(finland_entropy, us_entropy, taiwan_entropy) %>%
  left_join(populations, by='society') %>% 
  mutate(percent_population_byname = total_byname/population_total) %>% 
  left_join(us_pn_entropy %>% rbind(
    finland_pn_entropy, taiwan_pn_entropy 
  ), by='society') %>%
  mutate(percent_population_prefix = total_prefix/population_total) %>%
  pivot_longer(cols=c(entropy_byname, entropy_prefix), names_to = 'entropy_type', values_to = 'entropy') %>%
  rowwise() %>%
  mutate(entropy_upperbound = case_when(
    entropy_type == 'entropy_byname' ~ entropy + log2(population_total) - total_byname/population_total*log2(total_byname),
    entropy_type == 'entropy_prefix' ~ entropy + log2(population_total) - total_prefix/population_total*log2(total_prefix)
  ))

plot_prefix_name_vs_byname <- ggplot(entropy %>% 
         mutate(
           category = ifelse(entropy_type == 'entropy_prefix', 'prefix name entropy', 'byname entropy'),
           category =factor(category, levels=c('prefix name entropy', 'byname entropy'))), 
       aes(x=society, y=entropy, alpha = category)) +
  geom_col(position='dodge', width=0.5) +
  geom_errorbar(aes(ymax = entropy_upperbound, ymin=entropy), position='dodge', width=0.5) +
  theme_classic(18) +
  scale_alpha_discrete(range = c(0.5, 1))

pdf('imgs/prefix_name_vs_byname.pdf')
plot_prefix_name_vs_byname
dev.off()

save(plot_prefix_name_vs_byname, file='Data/plots_from_byname_analysis.RData')

