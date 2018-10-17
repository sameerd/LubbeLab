library(dplyr)
library(ggplot2)
library(scales)

ibd_file <- "data/working/beagle_output/ibd_out_1.ibd.gz"

x <- read.table(gzfile(ibd_file))

# make sure that the samples are ordered such that the 
# smaller one lexicographically appears first
all(as.character(x$sample1) < as.character(x$sample2))

colnames(x) <- c("sample1", "sample1idx", "sample2", "sample2idx", 
                 "chr", "startpos", "endpos", "lodscore", "lengthcm")

subx <- x %>% 
 filter(sample1 == "SS4009021") %>% 
 filter(sample2 == "SS4009023") %>% 
 filter(lodscore > 3) %>%
 identity()

#head(subx, 10)

sample1 = as.character(head(subx$sample1, 1))
sample2 = as.character(head(subx$sample2, 1))
chr = as.character(head(subx$chr, 1))

ggplot(subx, aes(xmin=sample1idx - 0.25,
                 xmax=sample1idx + 0.25,
                 ymin=startpos,
                 ymax=endpos)
      ) + theme(
        panel.grid.minor = element_blank()
      ) + scale_x_discrete(
        name=paste(head(subx$sample1, 1), "Haplotype Index"),
        limits=c("1", "2") 
      ) + scale_y_continuous(
        name="Chromosome Position",
        labels=scales::unit_format(unit="Mb", scale=1e-6)
      ) + geom_rect(
        aes(fill=factor(sample2idx))
      ) + ggtitle(
        paste0(sample1, "-", sample2, " : Chr", chr)
      ) + labs(
        fill = paste(sample2, "\nHapIndex")
      )

