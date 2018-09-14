#!/bin/bash

#MSUB -A b1049
#MSUB -e logs/errlog.dat
#MSUB -o logs/outlog.dat

set -x

# Set your working directory
# Required for quest
if [[ -v PBS_O_WORKDIR ]]; then cd $PBS_O_WORKDIR; fi

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

grep "^#" ${MERGED_VCF} > ${MERGE_PHASED}

# extract PGT information from merged file and pretend it is the genotype
grep -v "^#" ${MERGED_VCF} | \
       awk '{
          OFS="\t";
        }
        $9 ~ /PGT/ {
          split($9, rectype, ":") 
          split($10, G1, ":") 
          split($11, G2, ":") 
          split($12, G3, ":") 
          for (i in rectype) {
            if (rectype[i] == "PGT") break
          }
          if (G1[i] != "." && G2[i] != "." && G3[i] != "." && $5 != "." && $5 != "*") {
            print $1, $2, $3, $4, $5, $6, $7, $8, "GT", G1[i], G2[i], G3[i]
          }
        }' >> ${MERGE_PHASED}

