
input.file <- read.table("data/working/snp_variants.txt", header=TRUE, comment.char="")
colnames(input.file)[1:2] <- c("CHROMOSOME", "POSITION")

# FIXME: Look at chr1 only
genotypes <- input.file[input.file$CHROMOSOME == "chr1",]

# table that converts bp position to centimorgan
conversion <- read.table("data/working/hapmap/genetic_map_GRCh37_chr1.txt", header=TRUE)
colnames(conversion) <- c("CHROMOSOME", "POSITION", "RATE", "MAP")

# interpolate base pair position with conversion table to find genetic distance
interp <- approx(conversion$POSITION, conversion$MAP, xout=genotypes$POSITION)

# Write out MAP file for merlin
# This is CHROM, MARKER and POSITION in centimorgans
mapfile <- data.frame(CHROMOSOME=gsub("^chr", "", genotypes$CHROMOSOME),
                      MARKER=paste(genotypes$CHROMOSOME, genotypes$POSITION, sep="_"),
                      POSITION=interp$y)
write.table(mapfile, "data/working/family2.map", row.names=FALSE, 
            col.names=TRUE, quote=FALSE, sep="\t")

# Write out Merlin Dat File
#   family2.dat
#   ----------
#   A disease
#   M chr1_752721
datfile <- data.frame(CODE=rep("M", nrow(mapfile)),
                      DATATYPE=mapfile$MARKER)
datfile <- rbind(data.frame(CODE="A", DATATYPE="disease"), datfile) 
write.table(datfile, "data/working/family2.dat", row.names=FALSE,
            col.names=FALSE, quote=FALSE, sep="\t")

# Write out Merlin family pedigree file
#   family2.ped
#   -----------
#   1 1 0 0 2 1 x/x ...
#   1 2 0 0 1 1 x/x ...
#   1 3 2 1 1 2 0/0 ...
#   1 4 2 1 2 2 x/x ...
#   1 5 0 0 1 1 x/x ...
#   1 6 5 4 2 1 1/1 ...
#   1 7 5 4 1 2 x/x ...
#   1 8 0 0 2 1 x/x ...
#   1 9 7 8 2 2 0/1 ...

pedigree.string = '#
FAMILY PERSON FATHER MOTHER GENDER DISEASE
1 1 0 0 2 1
1 2 0 0 1 1
1 3 2 1 1 2
1 4 2 1 2 2
1 5 0 0 1 1
1 6 5 4 2 1
1 7 5 4 1 2
1 8 0 0 2 1
1 9 7 8 2 2'

small.pedigree.table <- read.table(text=pedigree.string, sep=" ", header=TRUE)

# a string for unknown genotypes
xx.string <- paste(rep("x/x", nrow(genotypes)), collapse=" ")

# Get the first few columns of the pedigree file
getSmallPedigree <- function(row.num, small.table=small.pedigree.table) {
   return (paste(small.table[row.num,], collapse=" "))
}

getGenotypeInMerlinFormat <- function(gt) {
  ## gt is a vector of genotypes 0/0, 1/1, ./. etc
  gt <- as.character(gt)
  ## replace . with 0
  gt <- gsub(".", "0", gt, fixed=TRUE)
  # # split the genotypes from x/x to x x
  # gt <- strsplit(gt, "/")

  # unlist creates a list in order then we collapse it
  return(paste(unlist(gt), collapse=" "))
}

# Create lists of the starting strings
small.ped.lines = lapply(1:nrow(small.pedigree.table), getSmallPedigree)
genotype.lines = lapply(1:nrow(small.pedigree.table), function(x) xx.string)
genotype.lines[3] <- getGenotypeInMerlinFormat(genotypes$SS4009021)
genotype.lines[7] <- getGenotypeInMerlinFormat(genotypes$SS4009023)
genotype.lines[9] <- getGenotypeInMerlinFormat(genotypes$SS4009030)

ped.lines <- lapply(1:nrow(small.pedigree.table), function(row.num) 
  paste(small.ped.lines[[row.num]], genotype.lines[[row.num]], sep=" ") )


file.con <- file("data/working/family2.ped")
writeLines(unlist(ped.lines), file.con)
close(file.con)



