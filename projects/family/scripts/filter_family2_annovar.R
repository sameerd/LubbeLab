# Here we take in an annovar filtered file and filter 
# it on the disease pattern. This is specific for each family
library(tidyverse)

# setwd("..")

# filename of the annovar output filtered file
input.filename <- system("source ./scripts/project_variables.bash; echo ${ANNOVAR_FILTERED}", 
                         intern=TRUE)

x <- read.table(input.filename, header=TRUE, sep="\t", comment.char="")
colnames(x)[1] <- "CHROM"

# family 2 sample names
sample.prefix = "SS400"
sample.names = paste0(sample.prefix, c("9021", "9023", "9030"))

# Only select a few columns to view
compact_viewer <-  function(z, n=1:4) z %>% select(n, sample.names)


# select sample column names
# but not the ones we want to keep
samples.to.drop <- select_vars(names(x), starts_with(sample.prefix), -sample.names)


# this code below ends up filtering out missing values only. ./.
# we do not have genotypes other than the ones specified below. 
# i.e. no 1/2, 2/0 etc
x_small <- x %>% 
  # convert genotype variables to character
  mutate_at(sample.names, funs(as.character(.)))  %>%
  # Make sure we only have bi-allelic variables
  filter_at(sample.names, all_vars(. %in% c("0/0", "0/1", "1/0", "1/1"))) %>%
  # drop all samples except the ones in our family
  select(-samples.to.drop)

#x_small %>% compact_viewer() %>% head()


x_filtered <- x_small %>%
  # keep rows where generation 1 is same as generation 3
  filter(SS4009021 == SS4009030) %>%
  # Since we decided that the disease is not in the reference genome
  # we can throw out 0/0 as well for the affected individuals G1 and G3
  filter(SS4009021 != "0/0" ) %>%
  # Keep rows when Generation 2 is different from generation 1
  filter(SS4009021 != SS4009023 ) %>%
  # Remove rows when Generation 2 is all alternate alleles 1/1
  # this means that G1 and G3 are both 0/1
  filter(SS4009023 != "1/1" ) %>%
  # Create a new column called SingleRefGene and split out ;
  mutate(SingleRefGene = Gene.refGene) %>%
  separate_rows(SingleRefGene, sep=";") %>%
  distinct() # because sometimes the ";" includes genes of the same name

#x_filtered %>% compact_viewer() %>% head()

x_dominant <- x_filtered %>%
  filter(SS4009021 == "0/1" | SS4009030 == "1/0") %>%
  filter(SS4009021 == "0/1" | SS4009030 == "1/0")

# save tables to disk
write.table(x_dominant, file="data/output/family2/dominant.txt", 
            sep="\t", quote=FALSE, row.names=FALSE)



