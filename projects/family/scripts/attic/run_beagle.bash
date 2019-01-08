#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

BEAGLE_OUTPUT_DIR="${WORKINGDIR}/beagle_output"
mkdir -p "${BEAGLE_OUTPUT_DIR}"

chr=1

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)
 
for chr in ${chromosomes[@]}; do
  ${JAVA} -jar ${BEAGLE_5_0} \
        gt=${WGS_ALL_VCF} \
        map="${BEAGLE_GENETIC_MAP_DIR}/plink.chr${chr}.GRCh37.map" \
        ref="${BEAGLE_BREF3_DIR}/chr${chr}.1kg.phase3.v5a.b37.bref3" \
        out=${BEAGLE_OUTPUT_DIR}/beagle_out_${chr} \
        chrom=${chr}
done


