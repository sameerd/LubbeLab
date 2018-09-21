#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

${BCFTOOLS} norm \
   -m -both \
   -f "${GENOMEREF}" \
   -o "${MERGED_VCF}" \
   "${MERGED2_VCF}" 



