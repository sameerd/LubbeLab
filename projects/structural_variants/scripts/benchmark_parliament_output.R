#This script benchmarks NA12878 output from parliament2

library(tidyverse)
library(fuzzyjoin)

# Pull in the Structural variants with some basic filtering
filtering.script <- '
  grep -v "^#" data/NA12878/NA12878_test.combined.genotyped.vcf | \
  awk -F"\t" \'{
    if (($5 == "<DEL>") && ($7 == "PASS")) 
      print $0}
    \'  ' 

x <- read.table(pipe(filtering.script), stringsAsFactors=FALSE)
colnames(x) <- c("CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", 
                 "INFO", "GT", "GTINFO")

# helper functions from https://rpubs.com/brunogrande/parse-vcf
row_tibble <- function(x, col_names) {
  tibble::as_tibble(rbind(setNames(x, col_names)))
}
parse_info <- function(info) {
  strsplit(info, ";", fixed = TRUE) %>%
    purrr::map(~row_tibble(sub("^.*=(.*)", "\\1", .x), sub("^(.*)=.*", "\\1", .x)))
}

info_as_df <- function(info) {
  # bind the resulting dataframes of parse_info rowwise
  bind_rows(parse_info(info))
}


# Extract info from the INFO field and create a dataframe for analysis
results <- x %>% 
  #we have already filtered by ALT and QUAL in the awk script
  select(-REF, -ALT, -QUAL, -GT, -GTINFO, -FILTER) %>% 
  # split the INFO column into new columns
  mutate(result = map(INFO, info_as_df)) %>% 
  unnest() %>%
  # remove the INFO column
  select(-INFO) %>%
  select(-AVGLEN, -SVMETHOD, -CIPOS, -CIEND, -STRANDS) %>%
  mutate(POS=as.integer(POS), END=as.integer(END)) %>%
  identity()


results %>% head

benchmark <- read.table("data/NA12878/NA12878_benchmark_no_chr.txt", 
                    	header=TRUE, sep="\t") %>%
  transmute(chromosome=paste0("chr", Chromosome), 
            POS=as.integer(Start.position), END=as.integer(End.position) )

benchmark %>% head




