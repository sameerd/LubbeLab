#!/bin/bash

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


