#This script benchmarks NA12878 output from parliament2

library(tidyverse)
library(fuzzyjoin)
library(ggplot2)

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
  transmute(CHROM=paste0("chr", Chromosome), 
            POS=as.integer(Start.position), END=as.integer(End.position) )

benchmark %>% head

p.reciprocal.overlap <- function(astart, aend, bstart, bend, p=0.5) {

  if (!is.na(astart) && !is.na(aend) && !is.na(bstart) && !is.na(bend)) {
    # From https://rdrr.io/bioc/chromswitch/man/pReciprocalOverlap.html
    a <- IRanges::IRanges(astart, aend)
    b <- IRanges::IRanges(bstart, bend)
  
    # look for an overlap of size p times the largest width of the two ranges
    minoverlap=max(p*IRanges::width(a), p*IRanges::width(b))  
    IRanges::overlapsAny(a, b, minoverlap=minoverlap) 
  } else { # one of input elements was NA
    FALSE
  }
}

# p.reciprocal.overlap(1, 10, 5, 15)
# p.reciprocal.overlap(1, 10, 5, NA)


benchmark.results <- fuzzyjoin::genome_join(benchmark, results, 
                                            by=c("CHROM", "POS", "END"),
                                            mode="left") %>%
  mutate(hit= purrr::pmap(list(astart=POS.x, aend=END.x,
                               bstart=POS.y, bend=END.y, p=0.5), 
                               p.reciprocal.overlap)) %>%
  tidyr::unnest() %>%
  # group by each SV in the benchmark and select only one result
  # preferably a true result with the highest support if one exists
  group_by(CHROM.x, POS.x, END.x) %>%
  mutate(hit.rank = rank(order(hit, SUPP), ties.method="first")) %>%
  filter(hit.rank == max(hit.rank)) %>%
  select(-hit.rank) %>%
  as.data.frame() 

benchmark.results %>% 
        nrow()


table(benchmark.results$hit, benchmark.results$SUPP)

#> table(benchmark.results$hit, benchmark.results$SUPP)                          
#         1   2   3   4   5                                                     
# FALSE   6   0   0   0   1                                                     
# TRUE   10  71 170 214 113  




 


