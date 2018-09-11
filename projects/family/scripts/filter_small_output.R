library(tidyverse)

# FIXME: Make this readable from the command line
x <- read.table("data/output/output.small.txt", header=TRUE, sep="\t")

plot(as.integer(x$G1))


children_vars <- c("C1", "C2")
parent_vars <- c("P1", "P2")

genotype_vars <- c("C1", "P1", "P2", "C2")

# Only select a few columns to view
compact_viewer <-  function(z, n=1:7) z %>% select(n, genotype_vars)

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
  filter(!((P1 == "0/0") & (P2 == "0/0"))) %>%
  # Create a new column called SingleRefGene and split out ;
  mutate(SingleRefGene = Gene.refGene) %>%
  separate_rows(SingleRefGene, sep=";") %>%
  distinct() # because sometimes the ";" includes genes of the same name


x_small %>% slice(1:10) %>% compact_viewer() 
 

# Pick out the homozygous variants
homo_variants <- x_small %>% 
  filter_at(children_vars, all_vars(.  == "1/1")) %>%
  filter_at(parent_vars, all_vars(. == "0/1")) %>%
  select(-SingleRefGene)


homo_variants %>% compact_viewer()

# Pick out the compound hetrozygous variants
compound_het_variants <- x_small %>%
  # children should both be 0/1
  filter_at(children_vars, all_vars(.  == "0/1")) %>%
  # One of the parents should be 0/1
  filter_at(parent_vars, any_vars(. == "0/1")) %>%
  # None of the parents should be 1/1
  filter_at(parent_vars, all_vars(. != "1/1")) %>%
  # Remove any genes that appear by themselves
  group_by(SingleRefGene) %>% filter(n() > 1) %>% 
  ungroup() %>% as.data.frame() %>%
  # paste all the genotypes together to create a family genotype
  mutate(FamilyGt=paste(C1, P1, P2, C2, sep=":")) %>% 
  group_by(SingleRefGene) %>%
  # There are either 1 or 2 family genotypes per gene
  # We are interested in the genes that have 2 family genotypes
  filter(n_distinct(FamilyGt) == 2) %>%
  ungroup() %>% as.data.frame() %>%
  select(-FamilyGt, -SingleRefGene)


compound_het_variants %>% compact_viewer() %>% select(-Alt) %>% head(200)


# save tables to disk
write.table(homo_variants, file="data/output/homozygous_variants.txt",
            sep="\t", quote=FALSE, row.names=FALSE)
write.table(compound_het_variants, file="data/output/compound_het_variants.txt",
            sep="\t", quote=FALSE, row.names=FALSE)



