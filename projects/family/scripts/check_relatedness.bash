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

$VCFTOOLS \
        --vcf "${MERGED_VCF}" \
        --out "${OUTPUT_VCFTOOLS}" \
        --relatedness2

$VCFTOOLS \
        --vcf "${MERGED_VCF}" \
        --out "${OUTPUT_VCFTOOLS}" \
        --relatedness


