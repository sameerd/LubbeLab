library(tidyverse)

# setwd("..")

# FIXME: Make this readable from the command line
x <- read.table("data/output/output.small.txt", header=TRUE, sep="\t")

genotype_vars <- c("G1", "G2", "G3")

# Only select a few columns to view
compact_viewer <-  function(z, n=1:7) z %>% select(n, genotype_vars)

x_small <- x %>% 
  # convert genotype variables to character
  mutate_at(genotype_vars, funs(as.character(.)))  %>%
  # Make sure we only have bi-allelic variables
  filter_at(genotype_vars, all_vars(. %in% c("0/0", "0/1", "1/0", "1/1"))) 

x_dominant <- x_small %>%
  filter(G1 == "0/1") %>%
  filter(G3 == "0/1")

x_filtered <- x_small %>%
  # keep rows where generation 1 is same as generation 3
  filter(G1 == G3) %>%
  # Keep rows when Generation 2 is different from generation 1
  filter(G1 != G2 ) %>%
  # Create a new column called SingleRefGene and split out ;
  mutate(SingleRefGene = Gene.refGene) %>%
  separate_rows(SingleRefGene, sep=";") %>%
  distinct() # because sometimes the ";" includes genes of the same name


x_filtered %>% slice(1:10) %>% compact_viewer() 

x_write <- x_filtered %>% select(-SingleRefGene) %>% distinct()

# save tables to disk
write.table(x_write, file="data/output/generation_variants.txt", 
            sep="\t", quote=FALSE, row.names=FALSE)
write.table(x_dominant, file="data/output/generation_variants_dominant.txt", 
            sep="\t", quote=FALSE, row.names=FALSE)



