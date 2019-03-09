library(tidyverse)

# select whether we are looking at the gangSTR output
is.filtered = ""
# or the vcf filtered with dumpSTR
is.filtered = ".filtered"

# pull in all the processed vcf files
get_filtered_vcf_file <- function(sample.name, 
                                  file.extension=paste0(is.filtered, ".txt")) {
  read.csv(paste0("data/working/gangstr/", sample.name, file.extension),
                  sep="\t", stringsAsFactors=FALSE, nrows=200000)
} 
x1 <- get_filtered_vcf_file("SS4009013")
x2 <- get_filtered_vcf_file("SS4009014")
x3 <- get_filtered_vcf_file("SS4009015")
x4 <- get_filtered_vcf_file("SS4009016")


get.new.column.names <- function(x, sample.extension=paste0(is.filtered, ".vcf")) {
  # one of the columns is the sample vcf filename. e.g. SS4009013.vcf
  # find out which one
  idx <- grep("SS400", colnames(x))
  if (length(idx) != 0) {
    # shorten the sample name to something like SS13
    sample.short.index <- gsub(paste0("SS40090([0-9]+)", sample.extension), "SS\\1", colnames(x)[idx])
    
    # Keep all columns below idx the same. Rename the idx column and the ones after
    # to look like SS13_[original_column_name]
    c(colnames(x)[1:(idx-1)], 
      paste0(sample.short.index, "_NUM"), 
      paste0(sample.short.index, "_", colnames(x[(idx+1):length(x)])))
  } else { # we could not find SS400 so return the same column names
    colnames(x)
  }
}

colnames(x1) <- get.new.column.names(x1)
colnames(x2) <- get.new.column.names(x2)
colnames(x3) <- get.new.column.names(x3)
colnames(x4) <- get.new.column.names(x4)


# merge all the data frames together
x <- x1 %>% inner_join(x2, by=c("CHROM", "POS", "END", "RU", "REF")) %>% 
            inner_join(x3, by=c("CHROM", "POS", "END", "RU", "REF")) %>% 
            inner_join(x4, by=c("CHROM", "POS", "END", "RU", "REF"))

colnames(x)
# remove input dataframes now that we have joined everything
#rm(x1, x2, x3, x4)



# let's remove all rows where this family has the same genotype
# these rows are not interesting. This removes 0/0 genotypes mostly
# For now let us assume that 0/1 and 1/0 are different 
x %<>% filter(! ((SS13_GT == SS14_GT) & (SS14_GT == SS15_GT) & 
                 (SS15_GT == SS16_GT)) ) %>%
       filter_at(vars(ends_with("_GT")), all_vars(. != "./.")) %>%
       filter_at(vars(ends_with("_GT")), all_vars(. != ".")) %>%
       identity()


# separate confidence interval columns
# converts resulting values to integer
separate_ci <- function(x, column) {
  # column looks like SS16_CI
  intermediate.columns =  paste(column, 1:2, sep="_")
  x %>% separate(!! column, sep=",", intermediate.columns) %>%
        separate(!! intermediate.columns[1], sep="-", 
                 paste(intermediate.columns[1], c("L", "U"), sep="_"),
                 convert=TRUE)  %>%
        separate(!! intermediate.columns[2], sep="-", 
                 paste(intermediate.columns[2], c("L", "U"), sep="_"),
                 convert=TRUE)  %>%
        identity()
}


# separate all confidence interval columns
x %<>% separate_ci("SS13_CI") %>%
  separate_ci("SS14_CI") %>%
  separate_ci("SS15_CI") %>%
  separate_ci("SS16_CI") %>%
  identity()


# Filtering on disease inheritance pattern
x.inherit <- x %>%
  # SS13 and SS16 should have their lower confidence values greater than reference
  filter((SS13_CI_1_L > REF) | (SS13_CI_2_L > REF)) %>%
  filter((SS16_CI_1_L > REF) | (SS16_CI_2_L > REF)) %>%
  # The lower confidence value of SS13 should be greater than the upper confidence
  # range of each of the parents
  filter(pmax(SS13_CI_1_L, SS13_CI_2_L) > pmax(SS14_CI_1_U, SS14_CI_2_U)) %>%
  filter(pmax(SS13_CI_1_L, SS13_CI_2_L) > pmax(SS15_CI_1_U, SS15_CI_2_U)) %>%
  # The lower confidence value of SS16 should be greater than the upper confidence
  # range of each of the grandparents
  filter(pmax(SS16_CI_1_L, SS16_CI_2_L) > pmax(SS14_CI_1_U, SS14_CI_2_U)) %>%
  filter(pmax(SS16_CI_1_L, SS16_CI_2_L) > pmax(SS15_CI_1_U, SS15_CI_2_U)) %>%
  identity()

working.gangstr.file <-  "data/working/family3_gangstr/annovar.tsv"

#db to send to annovar
# In order to send this to annovar we add a FAKEREF and FAKEWT column
# of zeros
x.annovar <- x.inherit %>% 
            mutate(CHROM=paste0("chr", CHROM)) %>%
            add_column(FAKEREF="0", .after="END") %>%
            add_column(FAKEWT="0", .after="FAKEREF")
write_tsv(x.annovar, working.gangstr.file, col_names=FALSE)

system(paste("/projects/b1049/genetics_programs/annovar_2017/annovar/table_annovar.pl",
        working.gangstr.file, 
       "/projects/b1049/genetics_programs/annovar_2017/annovar/humandb/ \\
       -buildver hg19 -otherinfo -protocol refGene,genomicSuperDups -operation g,r -nastring ." ))

# Pull in the annotated file and rename columns
multianno.output.file <- paste0(working.gangstr.file, ".hg19_multianno.txt")
ann <- read.csv(multianno.output.file, sep="\t", stringsAsFactors=FALSE, header=FALSE, skip=1)
# pull out the header column separately
ann.header <- strsplit(readLines(multianno.output.file, n=1), "\t")[[1]]

# The first 5 columns of x.annovar belong to Annovar and it rearrages them as it sees fit
# From column 6 onwards we have otherinfo. 
# So we pick the annovar headers from the annovar output file
# and we pick the otherinfo headers from the input file
colnames(ann) <- c(ann.header[1:(length(ann.header)-1)], 
                   colnames(x.annovar)[6:length(colnames(x.annovar))])


# Remove the fake columns and write out to file
# Also modify some scores and split intergenic genes into two columns
ann %>% 
  select(-Ref, -Alt)  %>%
  mutate(SingleRefGene = Gene.refGene) %>%
  separate_rows(SingleRefGene, sep=";") %>%
  extract(genomicSuperDups, into=c("superDupsScore"), 
          regex="Score=([0-9\\.]+);Name=", remove=TRUE) %>%
  replace_na(list(superDupsScore=".")) %>%
  distinct() %>%
  write_tsv("~/gangstr.family3.tsv")

