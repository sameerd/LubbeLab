#!/bin/bash

set -x

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
       && ($ix["genomicSuperDups"] == ".")  \
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

cut -f1-7,9,10,11,12,20,30 ${OUTPUT_TXT} \
      | paste - <(cut -f43 "${OUTPUT_TXT}" | awk -F: 'NR == 1 {print "G1"}; NR > 1 {print $1}') \
      | paste - <(cut -f44 "${OUTPUT_TXT}" | awk -F: 'NR == 1 {print "G2"}; NR > 1 {print $1}') \
      | paste - <(cut -f45 "${OUTPUT_TXT}" | awk -F: 'NR == 1 {print "G3"}; NR > 1 {print $1}') \
      > ${OUTPUT_TXT_SMALL}


