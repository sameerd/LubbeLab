library(tidyverse)

# pull in all the vcf files
x1 <- read.csv("data/working/gangstr/SS4009021.vcf", sep="\t", stringsAsFactors=FALSE)
x2 <- read.csv("data/working/gangstr/SS4009023.vcf", sep="\t", stringsAsFactors=FALSE)
x3 <- read.csv("data/working/gangstr/SS4009030.vcf", sep="\t", stringsAsFactors=FALSE)

# merge all the data frames together
x <- x1 %>% inner_join(x2) %>% inner_join(x3) 

strs <- x %>% 
   rename_at(vars(ends_with("vcf")), funs(gsub(".vcf","", .))) %>%
   separate(SS4009021, sep=",", c("i1s21","i2s21")) %>%
   separate(SS4009023, sep=",", c("i1s23","i2s23")) %>%
   separate(SS4009030, sep=",", c("i1s30","i2s30")) %>%
   identity()


# Remove everything where the family has equal counts
db <- strs %>% 
  filter( ! (   (i1s21 == i2s21) & (i2s21 == i1s23) & (i1s23 == i2s23) &
                (i2s23 == i1s30) & (i1s30 == i2s30)  )) %>% 
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

db %>% 
  mutate(m21 = pmax(as.integer(i1s21), as.integer(i2s21)),
         m23 = pmax(as.integer(i1s23), as.integer(i2s23)),
         m30 = pmax(as.integer(i1s30), as.integer(i2s30))) %>%
  filter(m21 > as.integer(REF)) %>% 
  filter(m30 > m21) %>% 
  filter(m30 > 2 * as.integer(REF)) %>% 
  filter(m21 > m23) %>% 
  #filter(RU == "ctg") %>%
  filter(str_length(RU) == 3) %>%
  select(-starts_with("m")) %>%
  identity() 




