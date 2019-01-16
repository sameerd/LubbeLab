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

# read in the hits file
hits <- read.table("data/output/family2/dominant.txt", sep="\t",
                    header=TRUE)

affected.family2.samplenames <-  select_vars(colnames(hits), starts_with("SS400"))

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
GetBeagleLod("chr10", 8000000, 
             affected.family2.samplenames[1], 
             affected.family2.samplenames[2],
             beagle.db=beagle.db)

beagle.annotated.hits <- hits %>%
  rowwise() %>%
  mutate(beagle_lod_21_30=GetBeagleLod(CHROM, POS, "SS4009021", "SS4009030", beagle.db)) %>%
  mutate(beagle_lod_21_23=GetBeagleLod(CHROM, POS, "SS4009021", "SS4009023", beagle.db)) %>%
  mutate(beagle_lod_23_30=GetBeagleLod(CHROM, POS, "SS4009023", "SS4009030", beagle.db)) %>%
  identity

write.table(beagle.annotated.hits %>% as.data.frame, 
            file="data/output/family2/dominant_beagle.txt", 
            sep="\t", quote=FALSE, row.names=FALSE)




