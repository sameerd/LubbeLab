# This script loads in a pre-computed beagle database and provides a query
# function GetBeagleLod. This function works one row at a time and is
# inefficient but usually isn't a problem with small lists of variants. 

library(tidyverse)

# read in beagle IBD output
family.shared.segments.script <- 'cat data/working/beagle_output/ibd_seq_*.ibd'
x <- read.table(pipe(family.shared.segments.script))
colnames(x) <- c("sample1", "hapindex1", "sample2", "hapindex2", "chr", 
                 "startpos", "endpos", "lod")
# save the output in a compatible db
beagle.db <- x %>%  
        mutate(chr = paste0("", chr)) %>%
        identity

GetBeagleLod <- function(chr, loc, sample1.name, sample2.name, beagle.db) {
  # Get the beagle lod score if we have a match
  filtered.db <- beagle.db %>% 
    # find the correct chromosome and correct samples
    filter(chr == !!chr 
           & sample1 %in% c(!!sample1.name, !!sample2.name) 
           & sample2 %in% c(!!sample1.name, !!sample2.name)) %>% 
    filter(startpos <= !!loc & endpos >= !!loc) %>%
    identity
  
  retval <- 0
  if (nrow(filtered.db) > 0) 
    retval <- max(filtered.db$lod)
  return(retval)
}

# testing out the function GetBeagleLod
#GetBeagleLod("chr10", 8000000, "SS4009021", "SS4009030", beagle.db=beagle.db)


