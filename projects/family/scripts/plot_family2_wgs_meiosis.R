library(dplyr)

x <- read.table("data/working/wgs_family2_patterns_small.txt")
colnames(x) <- c("chr", "startpos", "endpos", "ref", "alt", "freq", "gtalt", "G1", "G2", "G3")

x$freq <- as.numeric(as.character(x$freq))

genotype_vars <- c("G1", "G2", "G3")

x %>% 
  # convert genotype variables to character
  mutate_at(genotype_vars, funs(as.character(.)))  %>%
  # Make sure we only have bi-allelic variables
  filter_at(genotype_vars, all_vars(. %in% c("0/0", "0/1", "1/0", "1/1")))  %>%
  filter(!is.na(freq)) %>%
  select(-gtalt, -alt, -ref) %>%
  head(200)

