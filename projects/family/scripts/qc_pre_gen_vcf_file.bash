#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

module load java

# Now do QC for WES file
MAX_MISSING=0.1
MIN_GQ=80
MIN_DP=20

# calculate Ts/Tv ratio
$VCFTOOLS --vcf "${PRE_GEN_VCF_SORTED}" \
        --TsTv-summary \
        --out "${WORKINGDIR}/input_noQC" \
        --temp /tmp

# Filter Raw VCF to get only PASS variants
$VCFTOOLS --vcf "${PRE_GEN_VCF_SORTED}" \
    --remove-filtered-all \
    --recode \
    --recode-INFO-all \
    --out "${WORKINGDIR}/input_only_pass" \
    --temp /tmp

# convert MAX_MISSING to a percentage 
MAX_MISSING_PCT=$(awk "BEGIN{printf \"%.0f\", $MAX_MISSING * 100}")

VCF_BASE_FILE="input_only_pass_gq${MIN_GQ}_dp${MIN_DP}_cr${MAX_MISSING_PCT}"

# Set individual genotypes with low QC as missing and remove sites with 10% missing
$VCFTOOLS --vcf "${WORKINGDIR}/input_only_pass.recode.vcf"\
    --minGQ ${MIN_GQ} \
    --minDP ${MIN_DP} \
    --remove-filtered-geno-all \
    --max-missing ${MAX_MISSING} \
    --recode \
    --recode-INFO-all \
    --out "${WORKINGDIR}/${VCF_BASE_FILE}"

#Split multiallelic sitess
${BCFTOOLS} norm -m-both \
        -o "${WORKINGDIR}/step1_${VCF_BASE_FILE}.vcf" \
        "${WORKINGDIR}/${VCF_BASE_FILE}.recode.vcf"

#left normalization of indels
${BCFTOOLS} norm -f "${GENOMEREF}" \
        -o "${WORKINGDIR}/step2_${VCF_BASE_FILE}.vcf" \
         "${WORKINGDIR}/step1_${VCF_BASE_FILE}.vcf" \

#filter mssingness again
$VCFTOOLS --vcf "${WORKINGDIR}/step1_${VCF_BASE_FILE}.vcf"\
    --max-missing ${MAX_MISSING} \
    --recode \
    --recode-INFO-all \
    --out "${WORKINGDIR}/step2_${VCF_BASE_FILE}_2" \

# calculate Ts/Tv ratio
$VCFTOOLS --vcf "${WORKINGDIR}/step2_${VCF_BASE_FILE}_2.recode.vcf"  \
        --TsTv-summary \
        --out "${WORKINGDIR}/step2_${VCF_BASE_FILE}_2.summary" \
        --temp /tmp

cp "${WORKINGDIR}/step2_${VCF_BASE_FILE}_2.recode.vcf" \
  "${PRE_GEN_VCF_SORTED_QC}"




