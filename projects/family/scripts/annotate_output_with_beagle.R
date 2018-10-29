library(tidyverse)



family.shared.segments.script <- 'zcat data/working/beagle_output/ibd_out_*.ibd.gz'
x <- read.table(pipe(family.shared.segments.script))

colnames(x) <- c("sample1", "hapindex1", "sample2", "hapindex2", "chr", 
                 "startpos", "endpos", "lod", "size")

family2.samplenames <- paste0("SS40090", c("21", "23", "30"))

x %>% 
 filter(sample1 %in% family2.samplenames) %>%
 filter(sample2 %in% family2.samplenames) %>%
 tail




