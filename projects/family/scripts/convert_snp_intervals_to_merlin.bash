#!/bin/bash


source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

set -x

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
#${VCFTOOLS} --vcf "${SNP_CHIP_VCF}" --plink --chr chr1 --out "${PLINK_OUTPUT}"

grep -v "##" "${SNP_CHIP_VCF}" | \
  awk -F"\t" '
    function gt(s) { 
      split(s, a, ":"); 
      return a[1]
    } 
    { print $1, $2, gt($10), gt($11), gt($12) }' \
  >>  ${SNP_CHIP_VCF%.*}.txt

