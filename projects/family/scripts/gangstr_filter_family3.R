library(tidyverse)

# Common gangstr filtering 
source("scripts/gangstr_filter.R")

#is.filtered = ".filtered"
is.filtered = ""

x1 <- get_filtered_vcf_file_with_cols("SS4009013", is.filtered)
x2 <- get_filtered_vcf_file_with_cols("SS4009014", is.filtered)
x3 <- get_filtered_vcf_file_with_cols("SS4009015", is.filtered)
x4 <- get_filtered_vcf_file_with_cols("SS4009016", is.filtered)

# merge all the data frames together
x <- x1 %>% inner_join(x2, by=c("CHROM", "POS", "END", "RU", "REF")) %>% 
            inner_join(x3, by=c("CHROM", "POS", "END", "RU", "REF")) %>% 
            inner_join(x4, by=c("CHROM", "POS", "END", "RU", "REF"))

colnames(x)
# remove input dataframes now that we have joined everything
#rm(x1, x2, x3, x4)

# let's remove all rows where this family has the same genotype
# these rows are not interesting. This removes 0/0 genotypes mostly
# For now let us assume that 0/1 and 1/0 are different 
x %<>% filter(! ((SS13_GT == SS14_GT) & (SS14_GT == SS15_GT) & 
                 (SS15_GT == SS16_GT)) ) %>%
       filter_at(vars(ends_with("_GT")), all_vars(. != "./.")) %>%
       filter_at(vars(ends_with("_GT")), all_vars(. != ".")) %>%
       identity()

# separate all confidence interval columns
x %<>% separate_ci("SS13_CI") %>%
  separate_ci("SS14_CI") %>%
  separate_ci("SS15_CI") %>%
  separate_ci("SS16_CI") %>%
  identity()


# Filtering on disease inheritance pattern
x.inherit <- x %>%
  # SS13 and SS16 should have their lower confidence values greater than reference
  filter((SS13_CI_1_L > REF) | (SS13_CI_2_L > REF)) %>%
  filter((SS16_CI_1_L > REF) | (SS16_CI_2_L > REF)) %>%
  # The lower confidence value of SS13 should be greater than the upper confidence
  # range of each of the parents
  filter(pmax(SS13_CI_1_L, SS13_CI_2_L) > pmax(SS14_CI_1_U, SS14_CI_2_U)) %>%
  filter(pmax(SS13_CI_1_L, SS13_CI_2_L) > pmax(SS15_CI_1_U, SS15_CI_2_U)) %>%
  # The lower confidence value of SS16 should be greater than the upper confidence
  # range of each of the grandparents
  filter(pmax(SS16_CI_1_L, SS16_CI_2_L) > pmax(SS14_CI_1_U, SS14_CI_2_U)) %>%
  filter(pmax(SS16_CI_1_L, SS16_CI_2_L) > pmax(SS15_CI_1_U, SS15_CI_2_U)) %>%
  identity()

working.gangstr.file <-  "data/working/family3_gangstr/annovar.tsv"
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
  write_tsv("~/gangstr.family3.tsv")

