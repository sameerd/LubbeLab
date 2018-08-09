library(dplyr)

x <- read.table("data/output/output.small.txt", header=TRUE, sep="\t")


children_vars <- c("C1", "C2")
parent_vars <- c("P1", "P2")

genotype_vars <- c("C1", "P1", "P2", "C2")

# Only select a few columns to view
compact_viewer <-  function(z) z %>% select(1:7, genotype_vars)

x_small <- x %>% 
  # convert genotype variables to character
  mutate_at(genotype_vars, funs(as.character(.)))  %>%
  # Make sure we only have bi-allelic variables
  filter_at(genotype_vars, all_vars(. %in% c("0/0", "0/1", "1/1"))) %>%
  # Remove rows where the family has the same genotype
  filter(!((C1 == C2) & (C2 == P1) & (P1 == P2))) %>%
  # keep rows where both children have the same genotype
  filter(C1 == C2) %>%
  # Remove rows where any of the children are homozygous ref
  filter(C1 != "0/0", C2 != "0/0") %>%
  # Remove rows where both of the parents are homozygous ref
  filter(!((P1 == "0/0") & (P2 == "0/0")))


# Pick out the homozygous variants
homo_variants <- x_small %>% 
  filter_at(children_vars, all_vars(.  == "1/1")) %>%
  filter_at(parent_vars, all_vars(. == "0/1"))

homo_variants %>% compact_viewer()

compound_het_variants <- x_small %>%
   filter_at(children_vars, all_vars(.  == "0/1")) %>%
   head(8) %>% compact_viewer()



