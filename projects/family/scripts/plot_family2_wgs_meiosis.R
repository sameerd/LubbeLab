library(dplyr)
library(ggplot2)
library(scales)
library(reshape2)

x <- read.table("data/working/wgs_family2_patterns.txt")
colnames(x) <- c("chr", "startpos", "endpos", "ref", "alt", "freq", "gtalt", "G1", "G2", "G3")

x$freq <- as.numeric(as.character(x$freq))

genotype_vars <- c("G1", "G2", "G3")

x.filtered <- x %>% 
  # convert genotype variables to character
  mutate_at(genotype_vars, funs(as.character(.)))  %>%
  filter(chr == "chr1") %>%
  # Make sure we only have bi-allelic variables
  # CHECK there are no 1/0 in the dataset
  filter_at(genotype_vars, all_vars(. %in% c("0/0", "0/1", "1/1")))  %>%
  filter(as.character(alt) == as.character(gtalt)) %>%
  filter(!is.na(freq)) %>% 
  identity

x.chr1 <- x.filtered  %>%
  mutate(G1G2 = case_when(
        G1 == "0/1" & G2 == "0/1" ~ "shared",
        G1 == "1/1" & G2 == "0/1" ~ "shared",
        G1 == "0/1" & G2 == "1/1" ~ "notsure",
        G1 == "1/1" & G2 == "1/1" ~ "notsure",
        G1 == "0/0" & G2 == "0/0" ~ "noevidence",
        G1 == "1/1" & G2 == "0/0" ~ "unshared",
        G1 == "0/1" & G2 == "0/0" ~ "unshared",
        G1 == "0/0" & G2 == "0/1" ~ "unshared",
        G1 == "0/0" & G2 == "1/1" ~ "unshared" 
        )) %>%
  mutate(G1G3 = case_when(
        G1 == "0/1" & G3 == "0/1" ~ "shared",
        G1 == "1/1" & G3 == "0/1" ~ "shared",
        G1 == "0/1" & G3 == "1/1" ~ "notsure",
        G1 == "1/1" & G3 == "1/1" ~ "notsure",
        G1 == "0/0" & G3 == "0/0" ~ "noevidence",
        G1 == "1/1" & G3 == "0/0" ~ "unshared",
        G1 == "0/1" & G3 == "0/0" ~ "unshared",
        G1 == "0/0" & G3 == "0/1" ~ "unshared",
        G1 == "0/0" & G3 == "1/1" ~ "unshared" 
        )) %>%
  mutate(G2G3 = case_when(
        G2 == "0/1" & G3 == "0/1" ~ "shared",
        G2 == "1/1" & G3 == "0/1" ~ "shared",
        G2 == "0/1" & G3 == "1/1" ~ "notsure",
        G2 == "1/1" & G3 == "1/1" ~ "notsure",
        G2 == "0/0" & G3 == "0/0" ~ "noevidence",
        G2 == "1/1" & G3 == "0/0" ~ "unshared",
        G2 == "0/1" & G3 == "0/0" ~ "unshared",
        G2 == "0/0" & G3 == "0/1" ~ "unshared",
        G2 == "0/0" & G3 == "1/1" ~ "unshared" 
        )) %>%
  mutate(G1G2 = as.factor(G1G2)) %>%
  mutate(G1G3 = as.factor(G1G3)) %>%
  mutate(G2G3 = as.factor(G2G3)) %>%
  #slice(1:30) %>%
  identity 



ggplot(x.chr1, aes(startpos, G1G2)) + 
  geom_jitter(height=0.2, size=0.2) +
  scale_x_continuous(name="Chr Position",
        labels=scales::unit_format(unit="Mb", scale=1e-6)) + 
  labs(y='evidence from genotypes') +
  ggtitle("Chromosome 1 Genotype sharing between 9023 (neice) and 9021 (uncle)")
ggsave("~/chr1_G1G2.png")

ggplot(x.chr1, aes(startpos, G1G3)) + 
  geom_jitter(height=0.2, size=0.2) +
  scale_x_continuous(name="Chr Position",
        labels=scales::unit_format(unit="Mb", scale=1e-6)) + 
  labs(y='evidence from genotypes') +
  ggtitle("Chromosome 1 Genotype sharing between 9030 (grand-neice) and 9021 (grand-uncle)")
ggsave("~/chr1_G1G3.png")

ggplot(x.chr1, aes(startpos, G2G3)) + 
  geom_jitter(height=0.2, size=0.2) +
  scale_x_continuous(name="Chr Position",
        labels=scales::unit_format(unit="Mb", scale=1e-6)) + 
  labs(y='evidence from genotypes') +
  ggtitle("Chromosome 1 Genotype sharing between 9030 (child) and 9023 (aunt)")
ggsave("~/chr1_G2G3.png")

x.chr1.melt <- melt(x.chr1 %>% select(startpos, G1G2, G1G3, G2G3),
                   measure.vars=c("G1G2", "G1G3", "G2G3"), id.vars="startpos") %>% 
               filter(value == "shared") %>%
               mutate(variable = recode(variable, G1G2="9021-9023", 
                             G1G3="9021-9030", G2G3="9023-9030"))
x.chr1.melt%>%tail

# pull in hits file
variant_hits_file <- "data/output/family2/generation_variants.txt"
hits <- read.table(variant_hits_file, sep="\t", header=TRUE, 
                   stringsAsFactors=FALSE)
hits.chr1 <- hits %>% 
  filter(Chr == "chr1") %>% 
  mutate(startpos=Start) %>% 
  select(startpos, Gene.refGene) %>% 
  identity

ggplot(x.chr1.melt, aes(startpos, variable)) + 
  geom_jitter(height=0.2, size=0.2) +
  scale_x_continuous(name="Chr Position",
        labels=scales::unit_format(unit="Mb", scale=1e-6)) + 
  labs(y='evidence from genotypes') +
  ggtitle("Chromosome 1 Genotype sharing evidence") + 
  annotate("segment", x=hits.chr1$startpos, y=0.5, xend=hits.chr1$startpos + 1, 
           yend=Inf, colour="steelblue", alpha=0.5)
ggsave("~/chr1_family2.png")    


