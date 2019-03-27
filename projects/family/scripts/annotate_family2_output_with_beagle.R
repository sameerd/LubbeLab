source("scripts/beagle_db.R")

# read in the hits file
hits <- read.table("data/output/family2/dominant.txt", sep="\t",
                    header=TRUE)

affected.family2.samplenames <-  select_vars(colnames(hits), starts_with("SS400"))

beagle.annotated.hits <- hits %>%
  rowwise() %>%
  mutate(beagle_lod_21_30=GetBeagleLod(CHROM, POS, "SS4009021", "SS4009030", beagle.db)) %>%
  mutate(beagle_lod_21_23=GetBeagleLod(CHROM, POS, "SS4009021", "SS4009023", beagle.db)) %>%
  mutate(beagle_lod_23_30=GetBeagleLod(CHROM, POS, "SS4009023", "SS4009030", beagle.db)) %>%
  identity

write.table(beagle.annotated.hits %>% as.data.frame, 
            file="data/output/family2/dominant_beagle.txt", 
            sep="\t", quote=FALSE, row.names=FALSE)




