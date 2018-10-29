library(tidyverse)

# sample names
family2.samplenames <- paste0("SS40090", c("21", "23", "30"))
affected.family2.samplenames  <-  family2.samplenames[c(1,3)]

# read in beagle IBD output
family.shared.segments.script <- 'zcat data/working/beagle_output/ibd_out_*.ibd.gz'
x <- read.table(pipe(family.shared.segments.script))
colnames(x) <- c("sample1", "hapindex1", "sample2", "hapindex2", "chr", 
                 "startpos", "endpos", "lod", "size")
# save the output in a compatible db
beagle.db <- x %>%  
        mutate(chr = paste0("chr", chr)) %>%
        identity

# read in the hits file
hits <- read.table("data/output/family2/generation_variants_dominant.txt", sep="\t",
                    header=TRUE)

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
  mutate(Beagle_lod=GetBeagleLod(Chr, Start, "SS4009021", "SS4009030", beagle.db)) %>%
  identity

write.table(beagle.annotated.hits %>% as.data.frame, 
            file="data/output/family2/generation_variants_dominant_beagle.txt", 
            sep="\t", quote=FALSE, row.names=FALSE)




