#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

##first need to load the correct version of java (v2.8)
module load java

# Using GATK4 because of a bug in gatk3

tmp_vcf_file="${WORKINGDIR}/tmp_wgs_fam2.vcf"

${JAVA} -jar ${GATK}  \
   -T SelectVariants \
   -R "${GENOMEREF}" \
   -V "${WGS_ALL_FILTERED_VCF_hg19}" \
   -o "${tmp_vcf_file}" \
   -sn "SS400${G1}" \
   -sn "SS400${G2}" \
   -sn "SS400${G3}" \
   -L chr1:1-100000 \
   -env \
   -ef 


${JAVA} -jar ${GATK} \
   -R "${GENOMEREF}" \
   -V "${tmp_vcf_file}" \
   -T LeftAlignAndTrimVariants \
   -o "${WGS_FAM2_VCF}" \
   --splitMultiallelics

rm "${tmp_vcf_file}"




