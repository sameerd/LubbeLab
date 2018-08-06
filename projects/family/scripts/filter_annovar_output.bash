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

# First put the header in the output file
# This has a different number of columns than the rest of the file

# Now put in the other columns
awkcommand='
BEGIN {
  OFS="\t";
} 
NR==1 {
  print $0;
  for (i=1; i<=NF; i++) 
    ix[$i] = i
}
NR>1 {
  if (($ix["gnomAD_genome_ALL"] == "." || $ix["gnomAD_genome_ALL"] < 0.05 ) && $ix["CADD13_PHRED"] > 15 && ($ix["Func.refGene"] == "exonic" || $ix["Func.refGene"] == "exonic;splicing" || $ix["Func.refGene"] == "splicing" ) )
    print $0
}
'

awk -F'\t' "${awkcommand}" "${ANNOVAR_OUTPUT}"  > "$OUTPUT_TXT"


paste <(cut -f1-9,11,20 ${OUTPUT_TXT}) \
      <(cut -f46 "${OUTPUT_TXT}" | awk -F: '{print $1}') \
      | paste - <(cut -f47 "${OUTPUT_TXT}" | awk -F: '{print $1}') \
      | paste - <(cut -f48 "${OUTPUT_TXT}" | awk -F: '{print $1}') \
      | paste - <(cut -f49 "${OUTPUT_TXT}" | awk -F: '{print $1}') \
      >${OUTPUT_TXT_SMALL}

