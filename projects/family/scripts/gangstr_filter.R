library(tidyverse)
# These are common functionality to filter gangSTR output

# select whether we are looking at the gangSTR output
is.filtered = ""
# or the vcf filtered with dumpSTR
is.filtered = ".filtered"

# pull in all the processed vcf files
get_filtered_vcf_file <- function(sample.name, 
                                  file.extension=paste0(is.filtered, ".txt")) {
  read.csv(paste0("data/working/gangstr/", sample.name, file.extension),
                  sep="\t", stringsAsFactors=FALSE)
} 

get_new_column_names <- function(x, sample.extension=paste0(is.filtered, ".vcf")) {
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

get_filtered_vcf_file_with_cols <- function(sample.name, is.filtered) {
  x <- get_filtered_vcf_file(sample.name, 
                             file.extension=paste0(is.filtered, ".txt")) 
  colnames(x) <- get_new_column_names(x, 
                    sample.extension=paste0(is.filtered, ".vcf"))
  x
}


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

# annotate a dataframe with annovar
annotate_db <- function(x, working.gangstr.file) {
  # db to send to annovar
  # working.gangstr.file is where we store the file we sent to annovar 
  x.annovar <- x %>% 
            mutate(CHROM=paste0("chr", CHROM)) %>%
            add_column(FAKEREF="0", .after="END") %>%
            add_column(FAKEWT="0", .after="FAKEREF")
  write_tsv(x.annovar, working.gangstr.file, col_names=FALSE)

  # now call Annovar
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
  
  # Remove the fake columns and return
  ann %>% select(-Ref, -Alt) 
}

# find the maximum Repeat Allele length from STR catalog 
# Warning if we do not find the repeat we will return 0 for the maximum
get_repeat_max_from_catalog <- function(chrom, pos, catalog=c("SDP", "G1K")) {
  catalog_dir <- "/projects/b1049/genetics_programs/gangSTR/reference/"
  catalog_files <- list(SDP="sgdp.calls.vcf.gz", 
                        G1K="phase_1_final_calls.vcf.gz")

  catalog <- match.arg(catalog) 
  catalog_file <- paste0(catalog_dir, catalog_files[[catalog]])

  # remove chr/CHR from chrom variable
  chrom <- gsub("^chr", "", chrom, ignore.case=TRUE) 
  if (catalog == "G1K") { # add it back for 1000G as it uses hg19
    chrom <- paste0("chr", chrom)
  }
  tabix.query <- paste0("\"", chrom, ":", pos, "-", pos, "\"")
  #print(tabix.query)

  cmd <- paste("tabix", "-f", catalog_file, tabix.query,
               "| grep -oP 'RPA=\\K[^;]*' ", # Extract something like RPA=23,34,56;
               "| grep -o '[^,]\\+$' ") # Find the last number in this list above

  read.table(pipe(cmd), header=FALSE, col.names=c("val"))[1, 1]
}
#get_repeat_max_from_catalog("chr17", "49909028", catalog="G1K")


