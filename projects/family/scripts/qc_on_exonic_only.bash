#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

module load java


# Take the pre-gen vcf file and put in an ID column

# Create an ID column by merging chr_start_ref_alt
# replace *'s and .'s with zeros in the alt column
grep '^#' "$PRE_GEN_VCF" > "${PRE_GEN_VCF_ID}"
grep -v '^#' "$PRE_GEN_VCF" | \
  awk  -F'\t' \
    'BEGIN{OFS="\t"}
     {replace_star = $5;
      if ($5 == "." || $5 == "*") replace_star = "0";
      $3 = $1 "_" $2 "_" $4 "_" replace_star;
      print $0}'  \
  >> "${PRE_GEN_VCF_ID}" 

# from the annotated file extract the ID's that are exonic
awk -F'\t'  \
'BEGIN{OFS="\t"}
  {
    if ($6 == "exonic") {
      replace_star = $5;
      if ($5 == "." || $5 == "*") replace_star = "0";
      id = $1 "_" $2 "_" $4 "_" replace_star;
      print id
    }
  }' "${PRE_GEN_VCF_ANNO}"   > "$PRE_GEN_EXONIC_SNP"

# Calculate the Ts/Tv ratio on the exonic snps only
$VCFTOOLS --vcf "${PRE_GEN_VCF_ID}" \
        --TsTv-summary \
        --snps "${PRE_GEN_EXONIC_SNP}" \
        --out "${WORKINGDIR}/input_noQC" \
        --temp /tmp


