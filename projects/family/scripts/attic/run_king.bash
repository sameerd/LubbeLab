#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

cd ${WORKINGDIR}

# convert to bed file format
${PLINK} --vcf ${PRE_GEN_VCF_SORTED_QC} --make-bed --out all_plink

# create a family file with the trios marked
cat << EOF > ${PRE_GEN_VCF_SORTED_QC}
FAM3 SS4009013 2 SS4009014 SS4009015 -9
FAM3 SS4009014 1 0 0 -9
FAM3 SS4009015 2 0 0 -9
FAM3 SS4009016 1 0 0 -9
FAM1 SS4009017 1 SS4009018 SS4009019 -9
FAM1 SS4009018 1 0 0 -9
FAM1 SS4009019 2 0 0 -9
FAM1 SS4009020 2 SS4009018 SS4009019 -9
FAM2 SS4009021 0 0 0 -9
FAM2 SS4009023 0 0 0 -9
FAM2 SS4009030 0 0 0 -9
FAM4 SS4009022 0 0 0 -9
EOF

# run king (it will automatically pick up the all_plink.fam file)
${KING} -b all_plink.bed --bim all_plink.bim --ibdseg
