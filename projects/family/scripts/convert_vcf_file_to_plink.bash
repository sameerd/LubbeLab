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

awk '{if(+$1 >= 1 || $1 == "X" || $1 == "Y")
        print "chr" $1 ":" $2 "-" $2+1}' \
  "${SNP_CHIP_VARIANTS}" \
    > "${SNP_CHIP_INTERVALS}"

${JAVA} -jar ${GATK} \
  -T SelectVariants \
  -R "${GENOMEREF}" \
  -V "${MERGED_VCF}" \
  -L "${SNP_CHIP_INTERVALS}" \
  -o "${SNP_CHIP_VCF}"

# FIXME: Testing with chromosome 1 only
${VCFTOOLS} --vcf "${SNP_CHIP_VCF}" --plink --chr chr1 --out "${PLINK_OUTPUT}"
