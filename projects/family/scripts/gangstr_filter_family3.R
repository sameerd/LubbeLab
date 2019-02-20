library(tidyverse)

# pull in all the vcf files
x1 <- read.csv("data/working/gangstr/SS4009013.vcf", sep="\t", stringsAsFactors=FALSE)
x2 <- read.csv("data/working/gangstr/SS4009014.vcf", sep="\t", stringsAsFactors=FALSE)
x3 <- read.csv("data/working/gangstr/SS4009015.vcf", sep="\t", stringsAsFactors=FALSE)
x4 <- read.csv("data/working/gangstr/SS4009016.vcf", sep="\t", stringsAsFactors=FALSE)

# merge all the data frames together
x <- x1 %>% inner_join(x2) %>% inner_join(x3) %>% inner_join(x4)

strs <- x %>% 
   rename_at(vars(ends_with("vcf")), funs(gsub(".vcf","", .))) %>%
   separate(SS4009013, sep=",", c("i1s13","i2s13")) %>%
   separate(SS4009014, sep=",", c("i1s14","i2s14")) %>%
   separate(SS4009015, sep=",", c("i1s15","i2s15")) %>%
   separate(SS4009016, sep=",", c("i1s16","i2s16")) %>%
   identity()


# Remove everything where the family has equal counts
db <- strs %>% 
  filter( ! (   (i1s13 == i2s13) & (i2s13 == i1s14) & (i1s14 == i2s14) &
                (i2s14 == i1s15) & (i1s15 == i2s15) & (i2s15 == i1s16) &
                (i1s16 == i2s16)  )) %>% 
  identity()

db %>% filter(CHROM == "14", POS >= 55308000, POS <= 55370000 ) %>% 
        identity()


# pull in top 150 genes from genecards
dyt.genes <- read.table("data/input/dystonia_genes.txt")
colnames(dyt.genes) <- c("CHROM", "STRAND", "START", "END", "GENE")

dyt.genes %<>% 
  mutate(CHROM = gsub("^chr", "", CHROM)) %>% 
  group_by(GENE, CHROM) %>%
  summarize(START=as.integer(min(START)), END=as.integer(max(END))) %>%
  ungroup() %>%
  identity()


str.counts <- dyt.genes %>% split(.$GENE) %>% 
  map_dfr(function(x) {
    db %>% 
      filter(CHROM==!!x$CHROM[1], POS >= !!x$START[1], END <= !!x$END[1] ) %>% 
      identity()
  }, .id="GENE") %>% 
  identity()

str.counts %>% write.csv(., file="~/str.dystonia.filter.txt") 

db %>% nrow()

db %>% 
  mutate(m13 = pmax(as.integer(i1s13), as.integer(i2s13)),
         m14 = pmax(as.integer(i1s14), as.integer(i2s14)),
         m15 = pmax(as.integer(i1s15), as.integer(i2s15)),
         m16 = pmax(as.integer(i1s16), as.integer(i2s16))) %>%
  filter(m13 > as.integer(REF)) %>% 
  filter(m13 > m14) %>% 
  filter(m13 > m15) %>% 
  filter(m16 > m13) %>% 
  #filter(RU == "ctg") %>%
  filter(str_length(RU) == 3) %>%
  select(-starts_with("m")) %>%
  identity()




