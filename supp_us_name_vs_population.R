library(tidyverse)
library(ggplot2)
library(ggpubr)

pth <- 'Data/US_census_all'
us_states <- list.files(pth, "*.TXT")

read_files <- function(filename){
  d <- read.csv(paste0(pth, '/', filename), header = FALSE)
  colnames(d) = c('state', 'gender', 'year', 'name', 'frequency')
  return(d)
}

name_data_raw <- lapply(us_states, read_files) %>% bind_rows()

name_data <- name_data_raw %>%
  group_by(state, year) %>% 
  mutate(total = sum(frequency),
         p_name = frequency/total) %>%
  summarize(entropy = -sum(p_name * log(p_name)),
            perplexity = 2^entropy) %>% ungroup() %>%
  group_by(state) %>% mutate(entropy_rel_max = entropy/max(entropy),
                             perplexity_rel_max = perplexity/max(perplexity)) %>% ungroup()

decade_cutoffs <- seq(1910, 2018, 10)

# cumulative name entropy by decades
# name_data_cumulative <- name_data_raw %>% 
#   mutate(decade = floor(year/10) * 10) %>% 
#   group_by(state, name, decade) %>%
#   summarize(frequency_decade = sum(frequency)) %>% ungroup() %>%
#   group_by(state, decade) %>% 
#   mutate(total = sum(frequency_decade),
#          p_name = frequency_decade/total) %>%
#   summarize(entropy = -sum(p_name * log(p_name)),
#             perplexity = 2^entropy) %>% ungroup() %>%
#   group_by(state) %>% mutate(entropy_rel_max = entropy/max(entropy),
#                              perplexity_rel_max = perplexity/max(perplexity)) %>% ungroup()
# 
name_data_cumulative <- tibble()

for (decade in decade_cutoffs){
  name_data_sub <- name_data_raw %>%
    filter(year <= decade) %>%
    group_by(state) %>%
    mutate(total = sum(frequency),
           p_name = frequency/total) %>%
    summarize(entropy = -sum(p_name * log(p_name)),
              perplexity = 2^entropy) %>% ungroup() %>%
    mutate(cumulative_year = decade) %>%
    select(cumulative_year, state, entropy, perplexity)

  name_data_cumulative <- name_data_cumulative %>% rbind(name_data_sub)
  #name_data_cumulative <- append(name_data_cumulative, name_data_sub)
}

name_data_cumulative <- name_data_cumulative %>% group_by(state) %>%
  mutate(entropy_rel_max = entropy/max(entropy),
         perplexity_rel_max = perplexity/max(perplexity))

population_data <- read.csv('Data/us_population_change/population_change_data.csv') %>% 
  pivot_longer(cols=starts_with('census_'), names_to = 'year', values_to = 'population') %>% 
  mutate(year = as.numeric(str_sub(year, 8, -1))) %>%
  group_by(state) %>% mutate(population_rel_max = population/max(population)) %>% ungroup()

population_rank <- population_data %>% filter(year==2020) %>% select(state, population) %>%
  arrange(-population) %>% pull(state)

pdf("imgs/perplexity.pdf", height=9, width=12)
ggplot(name_data %>% mutate(state=factor(state, levels=population_rank)),
        aes(x=year, y=perplexity_rel_max)) +
  geom_point(color='#457B9D', alpha=0.4) +
  geom_line(color='#457B9D', alpha=0.2) +
  geom_point(data=population_data %>% mutate(state=factor(state, levels=population_rank)),
             aes(x=year, y=population_rel_max), color='#E63946') +
  geom_line(data=population_data %>% mutate(state=factor(state, levels=population_rank)),
            aes(x=year, y=population_rel_max), color='#E63946', alpha=0.5) +
  facet_wrap(~state) +
  theme_bw() +
  theme(strip.background = element_blank(),
        panel.grid = element_blank()) +
  ylab('normalized population (red) / perplexity (blue)') 
  #ggtitle('by-year name entropy')
dev.off()

ggplot(name_data_cumulative %>% mutate(state=factor(state, levels=population_rank)) %>%
         left_join(population_data, by=c('state', 'cumulative_year'='year')) %>% 
         mutate(relative_perplexity = perplexity_rel_max,
                relative_population = population_rel_max) %>% 
         select(state, cumulative_year, relative_perplexity, relative_population) %>% 
         pivot_longer(cols = c(relative_perplexity, relative_population), 
                      names_to = 'variable', values_to = 'normalized_value'),
        aes(x=cumulative_year, y=normalized_value, color=variable)) +
  geom_point() +
  geom_line() +
  scale_color_manual(values=c('#457B9D', '#E63946')) +
  facet_wrap(~state) +
  theme_bw() +
  theme(strip.background = element_blank(),
        panel.grid = element_blank()) +
  ylab('Relative perplexity or population') +
  labs(color='') +
  ggtitle('by-decade name entropy')


agg <- population_data %>% 
  inner_join(name_data, by=c('state', 'year')) 

ggplot(agg %>% mutate(state=factor(state, levels=population_rank)), aes(x=population_rel_max, y=perplexity_rel_max)) +
  geom_point(aes(color=year)) +
  geom_smooth(method='lm', alpha=0.1) +
  stat_cor(aes(label = paste(after_stat(r.label), after_stat(p.label), sep = "~`,`~")), 
               label.x=0.02, label.y=1.0, size=3, p.accuracy = 0.001) +
  scale_color_gradient(low='#03045E', high='#CAF0F8') +
  facet_wrap(~state) +
  theme_bw() +
  theme(strip.background = element_blank(),
        panel.grid = element_blank()) +
  ylab('') +
  ggtitle('by-year entropy')

agg_cumulative <- population_data %>%
  inner_join(name_data_cumulative, by=c('state', 'year'='cumulative_year'))
  
pdf("imgs/pop_and_by_decade_entropy.pdf", height=9, width=12)

ggplot(agg_cumulative %>% 
         mutate(state=factor(state, levels=population_rank)), aes(x=population_rel_max, y=perplexity_rel_max)) +
  geom_point(aes(color=year)) +
  geom_line(stat='smooth', method='lm', alpha=0.5) +
  geom_smooth(method='lm', alpha=0.1, size=0) +
  stat_cor(aes(label = paste(after_stat(r.label), after_stat(p.label), sep = "~`,`~")), 
           label.x=0.02, label.y=1.0, size=3, p.accuracy = 0.001) +
  scale_color_gradient(low='#03045E', high='#CAF0F8') +
  facet_wrap(~state) +
  theme_bw() +
  theme(strip.background = element_blank(),
        panel.grid = element_blank()) +
  xlab('Relative population') +
  ylab('Relative cumulative perplexity') +
  ggtitle('cumulative entropy') 

dev.off()

corrs <- agg_cumulative %>% 
  mutate(state=factor(state, levels=population_rank)) %>%
  group_by(state) %>%
  summarize(correlation = cor(population_rel_max, perplexity_rel_max, method='pearson'),
            p_value = cor.test(population_rel_max, perplexity_rel_max, method='pearson')$p.value)
  
ggplot(corrs %>% filter(p_value < 0.05), aes(x=state, y=correlation)) +
  geom_point()

name_50_states_agg <- lapply(us_states, read_files) %>% bind_rows() %>%
  filter(year==2018) %>%
  group_by(name) %>%
  summarize(total_number = n())


