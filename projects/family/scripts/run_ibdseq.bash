#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

mkdir -p "${BEAGLE_OUTPUT_DIR}"

#chr=1

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)
 
for chr in ${chromosomes[@]}; do
  ${JAVA} -jar ${IBDSEQ} \
        gt=${ALL_VCF_SORTED_QC} \
        out=${BEAGLE_OUTPUT_DIR}/ibd_seq_${chr} \
        chrom=chr${chr} \
        ibdlod=2.0 
done



