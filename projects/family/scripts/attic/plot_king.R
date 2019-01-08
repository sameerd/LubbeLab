library(dplyr)
library(ggplot2)
library(scales)
library(parallel)

# read in the king output file 
# some code from (http://people.virginia.edu/~wc9c/KING/king_segments_plot.R)

prefix <- "data/working/king"

#' file names
seg_name <- paste0(prefix, ".seg")
segments_name <- paste0(prefix, ".segments.gz")
all_seg_name <- paste0(prefix, "allsegs.txt")
if( !(file.exists(seg_name) & file.exists(segments_name) & file.exists(all_seg_name)) ) stop("Missing IBDSeg files")

#' load inference info
individuals_all <- read.table(seg_name, header = TRUE)
ind2nd3rd <- subset(individuals_all, InfType == "2nd/3rd", select = c(ID1, ID2))
indFS <- subset(individuals_all, InfType == "FS", select = c(ID1, ID2))

# segments considered
all_seg <- read.table(all_seg_name, header = TRUE)
all_seg <- subset(all_seg, select = c(Chr, StartMB, StopMB))
colnames(all_seg) <- c("chr", "start", "end")

# king segments gz file
segments <- read.table(segments_name, header = TRUE)
segments <- subset(segments, select = c(ID1, ID2, IBDType, Chr, StartMB, StopMB))
colnames(segments) <- c("ID1", "ID2", "IBDType", "chr", "start", "end")

family_samples <- c("SS4009017", "SS4009018")
id1 <- family_samples[1]
id2 <- family_samples[2]

subx <- subset(segments, ID1 == id1 & ID2 == id2)


## Taken from https://www.biostars.org/p/269857/
# hg19 chromosome sizes
chrom_sizes <- structure(list(V1 = c("chrM", "chr1", "chr2", "chr3", "chr4",
"chr5", "chr6", "chr7", "chr8", "chr9", "chr10", "chr11", "chr12",
"chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19",
"chr20", "chr21", "chr22", "chrX", "chrY"), V2 = c(16571L, 249250621L,
243199373L, 198022430L, 191154276L, 180915260L, 171115067L, 159138663L,
146364022L, 141213431L, 135534747L, 135006516L, 133851895L, 115169878L,
107349540L, 102531392L, 90354753L, 81195210L, 78077248L, 59128983L,
63025520L, 48129895L, 51304566L, 155270560L, 59373566L)), .Names = c("V1",
"V2"), class = "data.frame", row.names = c(NA, -25L))

# hg19 centromere locations
centromeres <- structure(list(X.bin = c(23L, 20L, 2L, 1L, 14L, 16L, 1L, 14L,
1L, 1L, 10L, 1L, 15L, 13L, 1L, 1L, 11L, 13L, 1L, 1L, 1L, 12L,
10L, 10L), chrom = c("chr1", "chr2", "chr3", "chr4", "chr5",
"chr6", "chr7", "chr8", "chr9", "chrX", "chrY", "chr10", "chr11",
"chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18",
"chr19", "chr20", "chr21", "chr22"), chromStart = c(121535434L,
92326171L, 90504854L, 49660117L, 46405641L, 58830166L, 58054331L,
43838887L, 47367679L, 58632012L, 10104553L, 39254935L, 51644205L,
34856694L, 16000000L, 16000000L, 17000000L, 35335801L, 22263006L,
15460898L, 24681782L, 26369569L, 11288129L, 13000000L), chromEnd = c(124535434L,
95326171L, 93504854L, 52660117L, 49405641L, 61830166L, 61054331L,
46838887L, 50367679L, 61632012L, 13104553L, 42254935L, 54644205L,
37856694L, 19000000L, 19000000L, 20000000L, 38335801L, 25263006L,
18460898L, 27681782L, 29369569L, 14288129L, 16000000L), ix = c(1270L,
770L, 784L, 447L, 452L, 628L, 564L, 376L, 411L, 583L, 105L, 341L,
447L, 304L, 3L, 3L, 3L, 354L, 192L, 125L, 410L, 275L, 22L, 3L
), n = c("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N",
"N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"
), size = c(3000000L, 3000000L, 3000000L, 3000000L, 3000000L,
3000000L, 3000000L, 3000000L, 3000000L, 3000000L, 3000000L, 3000000L,
3000000L, 3000000L, 3000000L, 3000000L, 3000000L, 3000000L, 3000000L,
3000000L, 3000000L, 3000000L, 3000000L, 3000000L), type = c("centromere",
"centromere", "centromere", "centromere", "centromere", "centromere",
"centromere", "centromere", "centromere", "centromere", "centromere",
"centromere", "centromere", "centromere", "centromere", "centromere",
"centromere", "centromere", "centromere", "centromere", "centromere",
"centromere", "centromere", "centromere"), bridge = c("no", "no",
"no", "no", "no", "no", "no", "no", "no", "no", "no", "no", "no",
"no", "no", "no", "no", "no", "no", "no", "no", "no", "no", "no"
)), .Names = c("X.bin", "chrom", "chromStart", "chromEnd", "ix",
"n", "size", "type", "bridge"), class = "data.frame", row.names = c(NA,
-24L))

# set the column names for the datasets
# IMPORTANT: fields common across datasets should have the same name in each
colnames(chrom_sizes) <- c("chromosome", "size")
colnames(centromeres) <- c('bin', "chromosome", 'start', 'end',
                       'ix', 'n', 'size', 'type', 'bridge')

# create an ordered factor level to use for the chromosomes in all the datasets
chrom_order <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7",
                 "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14",
                 "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21",
                 "chr22", "chrX", "chrY", "chrM")
chrom_key <- setNames(object = as.character(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                              12, 13, 14, 15, 16, 17, 18, 19, 20,
                                              21, 22, 23, 24, 25)),
                      nm = chrom_order)
chrom_order <- factor(x = chrom_order, levels = rev(chrom_order))

# convert the chromosome column in each dataset to the ordered factor
chrom_sizes[["chromosome"]] <- factor(x = chrom_sizes[["chromosome"]],
                                      levels = chrom_order)
centromeres[["chromosome"]] <- factor(x = centromeres[["chromosome"]],
                                      levels = chrom_order)
subx[["chromosome"]] <- factor(x=paste0("chr", subx[["chr"]]), levels=chrom_order)

subx$IBDType <- factor(subx$IBDType, levels = c("IBD0", "IBD1", "IBD2"))

ggplot(data=chrom_sizes) + 
    # base rectangles for the chroms, with numeric value for each chrom on the x-axis
    geom_rect(aes(xmin = as.numeric(chromosome) - 0.2,
                  xmax = as.numeric(chromosome) + 0.2,
                  ymax = size, ymin = 0),
              colour="black", fill = "white") +
    coord_flip() + 
    # add bands for centromeres
    geom_rect(data = centromeres, 
              aes(xmin = as.numeric(chromosome) - 0.2, 
                  xmax = as.numeric(chromosome) + 0.2, 
                  ymax = end, ymin = start)
              ) +
    geom_rect(data= subx, aes(
                 xmin=as.numeric(chromosome) - 0.2,
                 xmax=as.numeric(chromosome) + 0.2,
                 ymin=start * 1e6,
                 ymax=end * 1e6, 
                 fill=IBDType), alpha=0.5 ) +
    scale_fill_manual(values = c("IBD0" = "white", "IBD1" = "dodgerblue2", "IBD2" = "firebrick2"), drop = FALSE) + 
    theme( 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(size=0.1, color="white")) +    
    scale_y_continuous( 
        name="Chr Position",
        labels=scales::unit_format(unit="Mb", scale=1e-6)) + 
    scale_x_discrete(name = "chromosome", limits = names(chrom_key))  +
    theme(legend.position="bottom") +
    ggtitle("KING IBD results between 9017 and 9018")


ggsave("~/king_9017_9018.png")    
#ggsave("~/chr1_family1.png")    
