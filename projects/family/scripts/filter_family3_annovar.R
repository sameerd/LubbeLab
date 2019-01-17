# Here we take in an annovar filtered file and filter 
# it on the disease pattern. This is specific for each family
library(tidyverse)

# setwd("..")

# filename of the annovar output filtered file
input.filename <- system("source ./scripts/project_variables.bash; echo ${ANNOVAR_FILTERED}", 
                         intern=TRUE)

x <- read.table(input.filename, header=TRUE, sep="\t", comment.char="")
colnames(x)[1] <- "CHROM"

# family 3 sample names
sample.prefix = "SS400"
sample.names = paste0(sample.prefix, c("9014", "9015", "9013", "9016"))

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
  select(-samples.to.drop) %>%
  # change 1/0 to 0/1. Since the genotypes are unphased this is okay
  mutate_at(sample.names, funs(recode(., `1/0`="0/1")))


#x_small %>% compact_viewer() %>% head()


x_filtered <- x_small %>%
  # remove rows where all samples in the family have the same genotype
  filter(! (SS4009013 == SS4009014) & 
           (SS4009014 == SS4009015) &
           (SS4009015 == SS4009016)) %>%
  # Create a new column called SingleRefGene and split out ;
  mutate(SingleRefGene = Gene.refGene) %>%
  separate_rows(SingleRefGene, sep=";") %>%
  distinct() # because sometimes the ";" includes genes of the same name

  # Ressive pattern is empty
  #filter( SS4009013 == "1/1" & SS4009016 == "1/1" 
  #      & SS4009014 == "0/0" & SS4009015 == "0/0")

#x_filtered %>% compact_viewer() %>% head()

# save tables to disk
write.table(x_filtered, file="data/output/family3/variants.txt", 
            sep="\t", quote=FALSE, row.names=FALSE)



