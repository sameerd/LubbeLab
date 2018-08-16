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

${BCFTOOLS} norm \
   -m -both \
   -f "${GENOMEREF}" \
   -o "${MERGED_VCF}" \
   "${MERGED2_VCF}" 



