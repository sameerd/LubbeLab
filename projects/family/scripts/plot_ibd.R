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


family1 <- c("SS4009017", "SS4009018", "SS4009019", "SS4009020")
family2 <- c("SS4009021", "SS4009023", "SS4009030")

family_samples <- family2

subx <- x %>% 
 filter(sample1 %in% family_samples) %>% 
 filter(sample2 %in% family_samples) %>% 
 filter(lodscore > 1) %>%
 identity()

#head(subx, 10)

chr = as.character(head(subx$chr, 1))

ggplot(subx, aes(xmin=sample1idx - 0.25,
                 xmax=sample1idx + 0.25,
                 ymin=startpos,
                 ymax=endpos)) + 
    theme( 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(size=0.1, color="white")) +    scale_x_discrete( 
        name="Lower Sample Haplotype Index",
        limits=c("1", "2")) + 
    scale_y_continuous( 
        name="Chr Position",
        labels=scales::unit_format(unit="Mb", scale=1e-6)) + 
    geom_rect( aes(fill=factor(sample2idx))) + 
    ggtitle( paste("Chromosome", chr)) + 
    labs( fill = paste("Upper Sample\nHapIndex")) + 
    facet_wrap( ~sample2 + sample1) + 
    annotate("rect", xmin=c(1-0.25, 2-0.25), 
                     xmax=c(1+0.25, 2+0.25),
                     ymin=0, ymax=Inf, 
                     fill="grey", alpha=0.5, 
                     linetype=2, size=1)

ggsave("~/chr1_family2.png")    
#ggsave("~/chr1_family1.png")    
