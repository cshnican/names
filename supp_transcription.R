library(tidyverse)
library(readxl)
library(xtable)


# this script checks if the variation in spellings in Scottish names affects the entropy calculation

################################################
beith = read_excel("Data/Scotland/beith.xlsx", col_names = NA)
dingwall = read_excel("Data/Scotland/dingwall.xlsx", col_names = NA)
govan = read_excel("Data/Scotland/govan.xlsx", col_names = NA)
earlstone = read_excel("Data/Scotland/earlstone.xlsx", col_names = NA)
################################################
entropy_beith <- beith %>%
  mutate(locale = 'beith',
         tot = sum(`...4`),
         p = `...4`/tot) %>% 
  group_by(locale) %>%
  summarize(entropy=-sum(p*log2(p)))

entropy_dingwall <- dingwall %>%
  mutate(locale = 'dingwall',
         tot = sum(`...4`),
         p = `...4`/tot) %>% 
  group_by(locale) %>%
  summarize(entropy=-sum(p*log2(p)))

entropy_govan <- govan %>%
  mutate(locale = 'govan',
         tot = sum(`...4`),
         p = `...4`/tot) %>% 
  group_by(locale) %>%
  summarize(entropy=-sum(p*log2(p)))

entropy_earlstone <- earlstone %>%
  mutate(locale = 'earlstone',
         tot = sum(`...4`),
         p = `...4`/tot) %>% 
  group_by(locale) %>%
  summarize(entropy=-sum(p*log2(p)))
################################################
entropy <- bind_rows(
  entropy_beith, entropy_dingwall, entropy_earlstone, entropy_govan
)
