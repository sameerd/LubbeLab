#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

##first need to load the correct version of java (v2.8)
module load java

# FIXME: Need to remove idx files before running combine variants

${JAVA} -jar ${GATK} \
   -T CombineVariants \
   -R "${GENOMEREF}" \
   -V:P1,vcf "${P1_SORTED}" \
   -V:P2,vcf "${P2_SORTED}" \
   -V:C1,vcf "${C1_SORTED}" \
   -V:C2,vcf "${C2_SORTED}" \
   -o "${MERGED_VCF}" \
   -genotypeMergeOptions UNIQUIFY \
   -filteredRecordsMergeType KEEP_UNCONDITIONAL

# Remove the missed calls
# FIXME: use GENOTYPE_GIVEN_ALLELES or joint variant calling run
# https://gatkforums.broadinstitute.org/gatk/discussion/3707/merging-vcf-files-keeping-reference-alleles
sed 's/\.\/\./0\/0:0,999:99:9999,999,0/g' "${MERGED_VCF}" > "${MERGED2_VCF}"
mv "${MERGED2_VCF}" "${MERGED_VCF}"


