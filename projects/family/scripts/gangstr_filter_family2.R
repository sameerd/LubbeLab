library(tidyverse)

# Common gangstr filtering 
source("scripts/gangstr_filter.R")

#is.filtered = ".filtered"
is.filtered = ""

# pull in all the vcf files
x1 <- get_filtered_vcf_file_with_cols("SS4009021", is.filtered)
x2 <- get_filtered_vcf_file_with_cols("SS4009023", is.filtered)
x3 <- get_filtered_vcf_file_with_cols("SS4009030", is.filtered)

# merge all the data frames together
x <- x1 %>% inner_join(x2) %>% inner_join(x3) 

x %<>% filter(! ((SS21_GT == SS30_GT) & (SS21_GT == SS23_GT)) ) %>%
       filter_at(vars(ends_with("_GT")), all_vars(. != "./.")) %>%
       filter_at(vars(ends_with("_GT")), all_vars(. != ".")) %>%
       identity()

# separate all confidence interval columns
x %<>% separate_ci("SS21_CI") %>%
  separate_ci("SS23_CI") %>%
  separate_ci("SS30_CI") %>%
  identity()

# Filtering on disease inheritance pattern
x.inherit <- x %>%
  filter(SS21_GT != SS23_GT) %>%
  # SS21 and SS30 should have their lower confidence values greater than reference
  filter((SS21_CI_1_L > REF) | (SS21_CI_2_L > REF)) %>%
  filter((SS30_CI_1_L > REF) | (SS30_CI_2_L > REF)) %>%
  # The lower confidence value of SS21 and SS30 should be greater than the
  # upper confidence range of each of unaffected individuals
  filter(pmax(SS21_CI_1_L, SS21_CI_2_L) > pmax(SS23_CI_1_U, SS23_CI_2_U)) %>%
  filter(pmax(SS30_CI_1_L, SS30_CI_2_L) > pmax(SS23_CI_1_U, SS23_CI_2_U)) %>%
  # Now we find the maximum repeat from the catalog
  # this part is *very slow* as we have to do it row by row
  mutate(RPA_MAX=pmap(list(chrom=CHROM, pos=POS),
                           get_repeat_max_from_catalog,
                           catalog="SDP")) %>%
  # Filter the genotypes so that they are at least one of the affected individuals 
  # has a value greater than the max in the catalog
  filter(pmax(SS21_CI_1_L, SS21_CI_2_L) > RPA_MAX) %>%
  filter(pmax(SS30_CI_1_L, SS30_CI_2_L) > RPA_MAX) %>%
  identity()


working.gangstr.file <-  "data/working/family2_gangstr/annovar.tsv"
ann <- annotate_db(x.inherit, working.gangstr.file)

mds_genes <- read.table("data/input/mds_genes.txt")
colnames(mds_genes) <- "GENE"

ann %>%
  mutate(SingleRefGene = Gene.refGene) %>%
  mutate(MdsGene = SingleRefGene %in% mds_genes$GENE) %>%
  separate_rows(SingleRefGene, sep=";") %>%
  extract(genomicSuperDups, into=c("superDupsScore"), 
          regex="Score=([0-9\\.]+);Name=", remove=TRUE) %>%
  replace_na(list(superDupsScore=".")) %>%
  distinct() %>%
  write_tsv("~/gangstr.family2.tsv")



