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
  if (($ix["gnomAD_genome_ALL"] == "." \
          || $ix["gnomAD_genome_ALL"] < 0.05 ) \
       && ($ix["Func.refGene"] == "exonic" \
          || $ix["Func.refGene"] == "exonic;splicing" \
          || $ix["Func.refGene"] == "splicing" ) \
       && (($ix["ExonicFunc.refGene"] != "synonymous SNV" \
            && $ix["ExonicFunc.refGene"] != "nonsynonymous SNV") \
          || ($ix["ExonicFunc.refGene"] == "nonsynonymous SNV" \
            && ( 1 == 1 )) \
          || ($ix["ExonicFunc.refGene"] == "synonymous SNV" \
              && $ix["Func.refGene"] == "exonic;splicing" ) \
          ) \
    )
    print $0
}
'

awk -F'\t' "${awkcommand}" "${ANNOVAR_OUTPUT}"  > "$OUTPUT_TXT"

cut -f1-7,9,10,11,20 ${OUTPUT_TXT} \
      | paste - <(cut -f33 "${OUTPUT_TXT}" | awk -F: 'NR == 1 {print "G1"}; NR > 1 {print $1}') \
      | paste - <(cut -f34 "${OUTPUT_TXT}" | awk -F: 'NR == 1 {print "G2"}; NR > 1 {print $1}') \
      | paste - <(cut -f35 "${OUTPUT_TXT}" | awk -F: 'NR == 1 {print "G3"}; NR > 1 {print $1}') \
      > ${OUTPUT_TXT_SMALL}


