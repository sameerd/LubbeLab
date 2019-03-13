library(tidyverse)

x <- read.table("data/working/CA10", stringsAsFactors=FALSE)

# GTnames are the 9th column
gtsplit <- strsplit(x[1,9], ":")[[1]]
loc <- paste(x[1,1], x[1,2], sep=":")

# From the 10th onwards are the samples
x <- t(x[10:ncol(x)]) 

colnames(x) <- "gtinfo"

x.gt <- x %>% as.data.frame %>%
  separate(gtinfo, gtsplit, ':', convert=TRUE, fill="right") %>%
  drop_na %>% 
  separate(GB, paste0("GB", 1:2), "/", convert=TRUE) %>%
  mutate(RPLEN=21 + pmax(GB1, GB2) / 2) %>%
  mutate(DPCAT=cut(DP, breaks=c(-Inf, 3, 7, 12, Inf), 
                   labels=c("<3","3-7","7-12", ">12"))) %>%
  identity 

x.gt %>% nrow

library(ggplot2)
ggplot(x.gt, aes(RPLEN, colour=DPCAT)) + 
        geom_freqpoly() +
        labs(x="Repeat Length", y="Number of Samples", 
             title=loc, colour="Read Depth")

ggsave("~/lobstr.CA10.png")
