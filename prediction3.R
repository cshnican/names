library(tidyverse)
library(ggrepel)
library(gridExtra)
library(xtable)
library(stringdist)

# this file contains non-anonymous data and is available by request
# rename: to be less confusing
# first -> given
# last -> surname
d = read.csv("Data/downsampled_scinames.csv") 

# manually fixing crawling errors
# Andrew Yao's prefix- and bynames are flipped
d[d$name == 'Yao Andrew',] <- data.frame(
  '1152', 'Andrew Yao', NA, NA, 'Andrew', 'Yao', 'china', NA, 'Yao', NA, NA, NA, NA
)

# Chi-ming Che's prefix- and bynames are flipped
d[d$name == 'Che Chi-Ming',] <- data.frame(
  '376', 'Chi-Ming', NA, NA, 'Chiming', 'Che', 'china', NA, 'Che', NA, NA, NA, NA
)

d <- d %>%
  rename(given=first,
         surname=last,
         given.first=first.first,
         given.middle=first.middle) %>%
  mutate(given.init=substr(given, 1, 1),
         surname.init=substr(surname,1, 1),
         given.plus.surname=paste(given, surname),
         given.init.surname=paste(given.init, surname),
         given.surname.init=paste(given, surname.init)) %>%
  separate(given, sep="[ -]", into=c("x", 'middle'), remove=F) %>% 
  mutate(middle = ifelse(is.na(middle), "", middle),
         korean.given.two.surname=paste(toupper(substr(given, 1, 1)), toupper(substr(middle, 1, 1)), surname)) 



  
group_by(d, given) %>% summarise(n=n()) %>% arrange(-n)

# get median by country
s = median(table(d$country))

# Plot duplicate counts for each type of name
d.dupe = group_by(d, country) %>%
  filter(!grepl("patronym", country)) %>%
  summarise(`Full Name` = sum(duplicated(name)),
            `Flexible Given Name` = sum(duplicated(given)),
            `Fixed Inherited Name` = sum(duplicated(surname)),
            `Fiexible Given Name Init. + \nFixed Inherited Name` = sum(duplicated(given.init.surname)),
            `Flexible Given Name + \nFixed Inherited Name Init.` = sum(duplicated(given.surname.init))) %>%
  gather(variable, value, -country) %>%
  mutate(mean.value.per1000 = 1000 * (value/425),
         variable = gsub("\n", "", variable))

# for illustrations
dupe.helper = read_csv("data/plot_dupes_helper.csv")
#d.dupe$variable = gsub("\n", "", d.dupe$variable)
d.dupe.helper = left_join(dupe.helper, d.dupe) %>%
  mutate(IsClear = value < 30,
         Nonwestern = country %in% c('korea', 'china'),
         hasplus = grepl("\\+", variable),
         CountryImproved = factor(CountryImproved, levels=c("China", "South Korea", "Finland", "France", "Russia", "U.S.")),
         full.family = ifelse(variable %in% c("Fixed Inherited Name", "Fiexible Given Name Init. + Fixed Inherited Name"),
                              "Full Inherited Name",
                              "Full Given Name"),
         has.init = ifelse(grepl("Init", variable), "Initals", "No initials"))

p1 = ggplot(d.dupe.helper, aes(x=CountryImproved, y=value, alpha=IsClear, group=variable)) + geom_bar(stat='identity', position=position_dodge()) +
  theme_classic(12) +
  theme(axis.text.x = element_text(angle = 90),
        legend.position = "none")  +
  coord_flip() +
  geom_text(data=d.dupe.helper, aes(x=CountryImproved, y=0, label=example, group=variable),hjust=1, position= position_dodge(width = .9))  +
  scale_y_continuous(breaks=c(0, 100, 200,300), limits=c(-60, 350)) + 
  ylab("Number of Duplications") + xlab("") + 
  scale_alpha_discrete(range=c(.5, 1)) + 
  facet_grid( full.family ~ ., scales="free",space="free", drop=T) #

pdf('imgs/dupe_graph2.pdf', width=7, height=4)
p1
dev.off()

#ggsave("imgs/dupe_graph2.png", width=7, height=4)


maxdist = rep(1/max(table(d$country)), max(table(d$country)))
maxent = -sum(maxdist * log2(maxdist))


korea.new = d %>% 
  filter(country == 'korea') %>%
  mutate(country = 'Korea-2',
         given.init.surname =  paste(toupper(substr(given, 1, 1)),
                                  toupper(substr(middle, 1, 1)),
                                  surname))

russia.pat <- d %>%
  filter(country == 'russia_patronyms') %>%
  mutate(country = 'Russia-2',
         given.init.surname=paste(toupper(substr(given, 1, 1)),
                               toupper(substr(patronym, 1, 1)),
                               surname)
         )

d.ent.base = bind_rows(d %>% filter(grepl("patr", country) == F), korea.new, russia.pat)

given.surname.init.ent = group_by(d.ent.base, given.surname.init, country) %>%
  summarise(freq = n()/s) %>%
  group_by(country) %>%
  summarise(given.surname.init.ent = -sum(freq*log2(freq))) 

given.init.surname.ent = group_by(d.ent.base, given.init.surname, country) %>%
  summarise(freq = n()/s) %>%
  group_by(country) %>%
  summarise(given.init.surname.ent = -sum(freq*log2(freq)))

given.only.ent = group_by(d.ent.base, given, country) %>%
  summarise(freq = n()/s) %>%
  group_by(country) %>%
  summarise(given.only.ent = -sum(freq*log2(freq))) 

surname.only.ent = group_by(d.ent.base, surname, country) %>%
  summarise(freq = n()/s) %>%
  group_by(country) %>%
  summarise(surname.only.ent = -sum(freq*log2(freq))) 

d.ents = left_join(given.surname.init.ent, given.init.surname.ent, by='country') %>%
  left_join(given.only.ent, by='country') %>%
  left_join(surname.only.ent, by='country')

firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

d.ents[d.ents$country == "us", "country"] = "U.S."
d.ents[d.ents$country == "korea", "country"] = "Korea"

d.ents$country = firstup(d.ents$country)

p2 = ggplot(d.ents, aes(x=given.surname.init.ent, y=given.init.surname.ent, label=country)) +
  geom_text_repel(size=4) + 
  geom_hline(yintercept=maxent, lty="solid", colour="darkred", size=1, alpha=.5) +
  geom_vline(xintercept=maxent, lty="solid", colour="darkred", size=1, alpha=.5) + 
  geom_abline(slope=1, intercept=0, linetype='dashed', colour='gray') +
  geom_point() + 
  coord_fixed() +
  xlim(7, 8.8) +
  ylim(7, 8.8) +
  xlab("flexible given name + fixed inherited initial entropy\n(Charles D. / Xiaoping L.)") + 
  ylab("flexible given name initial + fixed inherited name entropy\n(C. Darwin / X. Li)")+
  theme_bw(14) 

p2_alternative = ggplot(d.ents %>% 
                          pivot_longer(cols=-country, names_to = 'name_style', values_to = 'entropy') %>%
                          mutate(country = factor(country, levels=c('China', 'Korea', 'Korea-2', 'Russia', 'Russia-2', 'Finland', 'France', 'U.S.'))) %>%
                          filter(!country %in% c('Korea-2', 'Russia-2')),
                        aes(x=country, y=entropy)) +
  facet_wrap(~name_style) +
  coord_flip() +
  geom_col() +
  theme_classic(25) +
  geom_vline(xintercept = 2.5, linetype='dashed') +
  geom_hline(yintercept=maxent, lty="solid", size=1, alpha=.5) 
  
pdf("imgs/double_scinames.pdf", width=15, height=6)
grid.arrange(p1, p2, ncol=2)
dev.off()

# get number of neighbors for each word
get.neighbors.per.word = function(ctry, column) {
  co = filter(d, country == ctry)
  group_by(co, country) %>%
    mutate(neighbors = 
             sum(sapply(co[, column], function(x) 
             {stringdist(x, rlang::sym(column))}) == 1)
    ) %>%
    select(rlang::sym(column), neighbors)
}


china = filter(d, country == "china")
china.usway = group_by(china, country) %>%
  mutate(neigh = 
           rowSums(sapply(china$given.init.surname, function(x) 
           {stringdist(x, china$given.init.surname)}) <= 1) - 1
  ) %>%
  select(name=given.init.surname, neigh) %>%
  mutate(mode = "X. Li", #"China (given init. + family name):\nX. Li",
         type = "given init.")

china.chinaway = group_by(china, country) %>%
    mutate(neigh =
             rowSums(sapply(china$given.surname.init, function(x)
             {stringdist(x, china$given.surname.init)}) <= 1) - 1
    ) %>%
    select(name=given.surname.init, neigh) %>%
    mutate(mode = "Xiaoping L.", #"China (family init. + given name):\nL. Xiaoping",
           type = "inherited init.")

us = filter(d, country == "us")
us.usway = group_by(us, country) %>%
  mutate(neigh =
           rowSums(sapply(us$given.init.surname, function(x)
           {stringdist(x, us$given.init.surname)}) <= 1) - 1
  ) %>%
  select(name=given.init.surname, neigh) %>%
  mutate(mode = "J. Smith", #"US (given init. + family name):\nJ. Smith",
         type = "given init.")

us.chinaway = group_by(us, country) %>%
  mutate(neigh =
           rowSums(sapply(us$given.surname.init, function(x)
           {stringdist(x, us$given.surname.init)}) <= 1) - 1
  ) %>%
  select(name=given.surname.init, neigh) %>%
  mutate(mode = "Jamal S.", #"US (given name + family init.):\nJamal S.",
         type = "inherited init.")

korea = filter(d, country == "korea")
korea.usway = group_by(korea, country) %>%
  mutate(neigh =
           rowSums(sapply(korea$given.init.surname, function(x)
           {stringdist(x, korea$given.init.surname)}) <= 1) - 1
  ) %>%
  select(name=given.init.surname, neigh) %>%
  mutate(mode = "S. Kim", #"Korea (given init. + family name):\nS. Kim",
         type = "given init.")

korea.chinaway = group_by(korea, country) %>%
  mutate(neigh =
           rowSums(sapply(korea$given.surname.init, function(x)
           {stringdist(x, korea$given.surname.init)}) <= 1) - 1
  ) %>%
  select(name=given.surname.init, neigh) %>%
  mutate(mode = "Sang Yong K.", #"Korea (family init. + given name):\nK. Sang Yong",
         type = "inherited init.")

france = filter(d, country == "france")
france.usway = group_by(france, country) %>%
  mutate(neigh =
           rowSums(sapply(france$given.init.surname, function(x)
           {stringdist(x, france$given.init.surname)}) <= 1) - 1
  ) %>%
  select(name=given.init.surname, neigh) %>%
  mutate(mode = "M. Curie",#"France (given init. + family name):\nM. Curie",
         type = "given init.")

france.chinaway = group_by(france, country) %>%
  mutate(neigh =
           rowSums(sapply(france$given.surname.init, function(x)
           {stringdist(x, france$given.surname.init)}) <= 1) - 1
  ) %>%
  select(name=given.surname.init, neigh) %>%
  mutate(mode = "Marie C.", #"France (given name + family init.):\nMarie C.",
         type = "inherited init.")

russia = filter(d, country == "russia")
russia.usway = group_by(russia, country) %>%
  mutate(neigh =
           rowSums(sapply(russia$given.init.surname, function(x)
           {stringdist(x, russia$given.init.surname)}) <= 1) - 1
  ) %>%
  select(name=given.init.surname, neigh) %>%
  mutate(mode = "A. Kolmogorov", #"Russia (given init. + family name):\nA. Kolmogorov",
         type = "given init.")

russia.chinaway = group_by(russia, country) %>%
  mutate(neigh =
           rowSums(sapply(russia$given.surname.init, function(x)
           {stringdist(x, russia$given.surname.init)}) <= 1) - 1
  ) %>%
  select(name=given.surname.init, neigh) %>%
  mutate(mode = "Andrey K.", #"Russia (given name + family init.):\nAndrey K.",
         type = "inherited init.")

finnish = filter(d, country == "finland")
finnish.usway = group_by(finnish, country) %>%
  mutate(neigh =
           rowSums(sapply(finnish$given.init.surname, function(x)
           {stringdist(x, finnish$given.init.surname)}) <= 1) - 1
  ) %>%
  select(name=given.init.surname, neigh) %>%
  mutate(mode = "E. Saarinen", #"Finland (given init. + family):\nE. Saarinen",
         type = "given init.")

finnish.chinaway = group_by(finnish, country) %>%
  mutate(neigh =
           rowSums(sapply(finnish$given.surname.init, function(x)
           {stringdist(x, finnish$given.surname.init)}) <= 1) - 1
  ) %>%
  select(name=given.surname.init, neigh) %>%
  mutate(mode = "Eero S.", #"Finland (given + family init.):\nEero S.",
         type = "inherited init.")


neighs = bind_rows(china.usway, us.usway, us.chinaway, china.chinaway,
                   korea.usway, korea.chinaway, france.usway, france.chinaway,
                   russia.usway, russia.chinaway,
                   finnish.usway, finnish.chinaway)


neighs$type.pretty = ifelse(neighs$type == "flexible given init.", "flexible given init. + fixed inherited name (C. Darwin / X. Li)",
                            "flexible given name + fixed inherited init. (Charles D. / Xiaoping L.)")

neighbors.per.1000 = group_by(neighs, country, mode, type) %>%
  summarise(mean.neighbors.per.1000 = 1000 * mean(neigh)/n()) %>%
  mutate(mode = factor(mode, levels = c(
    "X. Li", "Xiaoping L.", "E. Saarinen", "Eero S.", "M. Curie", "Marie C.", "S. Kim", "Sang Yong K.", "A. Kolmogorov", "Andrey K.",
    "J. Smith", "Jamal S.")
  ),
  country = ifelse(country == 'us', 'US', str_to_title(country)))

group_by(neighs, mode) %>%
  summarise(m=mean(neigh))

group_by(neighs, mode) %>%
  mutate(m=max(neigh)) %>%
  filter(neigh == m) %>%
  data.frame()

p3 <- ggplot(neighbors.per.1000, aes(x=mode, y=mean.neighbors.per.1000, alpha=as.factor(type))) +
    geom_col() +
    facet_wrap(~country, scales='free_x', ncol = 3) +
    theme_classic(18) +
    theme(#axis.text.x = element_text(angle=90),
      panel.grid = element_blank(),
      legend.title = element_blank(),
      legend.position = 'bottom') +
    # scale_fill_manual(
    #   values=c('navy', 'orange') 
    # ) +
    scale_alpha_discrete(range=c(.5, 1)) + 
    ylab('Mean number of neighbors per 1000') 


pdf('imgs/number_of_neighbors.pdf', width=14, height=8)
p3
dev.off()

pdf("imgs/triple_scinames.pdf", width=15, height=15)
grid.arrange(p1, p2, p3, ncol=2, layout_matrix=cbind(c(1,3), c(2,3)))
dev.off()

save(p1, p2, p3, file='Data/exp3plots.RData')

# analyzing prefix-name and byname entropy

d.prefix.name.and.byname <- d %>% select(
  name, given, surname, country
) %>%
  filter(country != 'russia_patronyms') %>%
  mutate(prefix.name = ifelse(country %in% c('korea', 'china'), surname, given),
         byname = ifelse(country %in% c('china', 'korea'), given, surname)) %>%
  select(-given, -surname)

d.ent.prefix_name <- d.prefix.name.and.byname %>%
  group_by(country) %>%
  mutate(tot = n()) %>% ungroup() %>%
  group_by(country, prefix.name, tot) %>%
  summarize(freq = n()) %>%
  mutate(prefix_name.frequency = freq/tot) %>% ungroup() %>%
  group_by(country) %>%
  summarize(prefix_name.entropy = -sum(prefix_name.frequency*log2(prefix_name.frequency)))
  
d.ent.byname <- d.prefix.name.and.byname %>%
  group_by(country) %>%
  mutate(tot = n()) %>% ungroup() %>%
  group_by(country, byname, tot) %>%
  summarize(freq = n()) %>%
  mutate(byname.frequency = freq/tot) %>% ungroup() %>%
  group_by(country) %>%
  summarize(byname.entropy = -sum(byname.frequency*log2(byname.frequency)))

# calculate conditional entropy
conditional_entropy <- d.prefix.name.and.byname %>% 
  group_by(country) %>%
  mutate(total = n()) %>% ungroup() %>%
  group_by(country, prefix.name) %>%
  mutate(p.prefix.name = n()/total) %>% ungroup() %>%
  group_by(country, prefix.name, byname) %>%
  mutate(p.prefix.name.byname = n()/total) %>% ungroup() %>%
  select(country, prefix.name, byname, p.prefix.name, p.prefix.name.byname) %>% distinct() %>%
  mutate(p.byname.given.prefix.name = p.prefix.name.byname/p.prefix.name) %>% 
  group_by(country) %>%
  summarise(conditional_entropy = -sum(p.prefix.name.byname*log2(p.byname.given.prefix.name)))

total_entropy <- d.prefix.name.and.byname %>% 
  group_by(country) %>%
  mutate(total = n()) %>% ungroup() %>%
  group_by(country, prefix.name, byname) %>%
  mutate(p.prefix.name.byname = n()/total) %>% ungroup() %>%
  select(country, prefix.name, byname, p.prefix.name.byname) %>% distinct() %>%
  group_by(country) %>%
  summarise(total_entropy = -sum(p.prefix.name.byname*log2(p.prefix.name.byname)))



tab <- left_join(
  d.ent.prefix_name, d.ent.byname, by='country'
) %>% 
  left_join(
    conditional_entropy, by='country'
    ) %>% 
  left_join(
    total_entropy, by='country'
  ) 

ggplot(tab %>% pivot_longer(cols = -country, names_to = "category", values_to = "value") %>%
         mutate(category=factor(category, levels=c('prefix_name.entropy', 'conditional_entropy', 'byname.entropy', 'total_entropy'))), 
       aes(x=country, y=value, fill=category)) +
  geom_col(position='dodge') +
  theme_classic(18)

tab %>% xtable()












 