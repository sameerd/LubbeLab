library(tidyverse)

# pull in all the processed vcf files
x1 <- read.csv("data/working/gangstr/SS4009013.txt", sep="\t", stringsAsFactors=FALSE)
x2 <- read.csv("data/working/gangstr/SS4009014.txt", sep="\t", stringsAsFactors=FALSE)
x3 <- read.csv("data/working/gangstr/SS4009015.txt", sep="\t", stringsAsFactors=FALSE)
x4 <- read.csv("data/working/gangstr/SS4009016.txt", sep="\t", stringsAsFactors=FALSE)


get.new.column.names <- function(x) {
  # one of the columns is the sample vcf filename. e.g. SS4009013.vcf
  # find out which one
  idx <- grep("SS400", colnames(x))
  if (length(idx) != 0) {
    # shorten the sample name to something like SS13
    sample.short.index <- gsub("SS40090([0-9]+).vcf", "SS\\1", colnames(x)[idx])
    
    # Keep all columns below idx the same. Rename the idx column and the ones after
    # to look like SS13_[original_column_name]
    c(colnames(x)[1:(idx-1)], 
      paste0(sample.short.index, "_NUM"), 
      paste0(sample.short.index, "_", colnames(x[(idx+1):length(x)])))
  } else { # we could not find SS400 so return the same column names
    colnames(x)
  }
}

colnames(x1) <- get.new.column.names(x1)
colnames(x2) <- get.new.column.names(x2)
colnames(x3) <- get.new.column.names(x3)
colnames(x4) <- get.new.column.names(x4)

# merge all the data frames together
x <- x1 %>% inner_join(x2, by=c("CHROM", "POS", "END", "RU", "REF")) %>% 
            inner_join(x3, by=c("CHROM", "POS", "END", "RU", "REF")) %>% 
            inner_join(x4, by=c("CHROM", "POS", "END", "RU", "REF"))

colnames(x)
# remove input dataframes now that we have joined everything
rm(x1, x2, x3, x4)

table(x$SS13_GT)
x %>% head(2)

# let's remove all rows where this family has the same genotype
# these rows are not interesting. This removes 0/0 genotypes mostly
# For now let us assume that 0/1 and 1/0 are different 
x %<>% filter(! ((SS13_GT == SS14_GT) & (SS14_GT == SS15_GT) & 
                 (SS15_GT == SS16_GT)) ) %>%
       identity()

# separate confidence interval columns
# converts resulting values to integer
separate_ci <- function(x, column) {
  # column looks like SS16_CI
  intermediate.columns =  paste(column, 1:2, sep="_")
  x %>% separate(!! column, sep=",", intermediate.columns) %>%
        separate(!! intermediate.columns[1], sep="-", 
                 paste(intermediate.columns[1], c("L", "U"), sep="_"),
                 convert=TRUE)  %>%
        separate(!! intermediate.columns[2], sep="-", 
                 paste(intermediate.columns[2], c("L", "U"), sep="_"),
                 convert=TRUE)  %>%
        identity()
}

# separate all confidence interval columns
x %<>% separate_ci("SS13_CI") %>%
  separate_ci("SS14_CI") %>%
  separate_ci("SS15_CI") %>%
  separate_ci("SS16_CI") %>%
  identity()

# Filtering on disease pattern
x %>%
  # SS13 and SS16 should have their lower confidence values greater than reference
  filter((SS13_CI_1_L > REF) | (SS13_CI_2_L > REF)) %>%
  filter((SS16_CI_1_L > REF) | (SS16_CI_2_L > REF)) %>%
  # The lower confidence value of SS13 should be greater than the upper confidence
  # range of each of the parents
  filter(pmax(SS13_CI_1_L, SS13_CI_2_L) > pmax(SS14_CI_1_U, SS14_CI_2_U)) %>%
  filter(pmax(SS13_CI_1_L, SS13_CI_2_L) > pmax(SS15_CI_1_U, SS15_CI_2_U)) %>%
  # The last generation should have a lower confidence value greater than 
  # the upper confidence values of the previous generation
  filter(pmax(SS16_CI_1_L, SS16_CI_2_L) > pmax(SS13_CI_1_U, SS13_CI_2_U))  %>%
  head()

