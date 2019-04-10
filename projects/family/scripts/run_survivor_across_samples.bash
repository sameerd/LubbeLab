#!/bin/bash

#run Survivor across samples and run Survivor annotation

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

cd "${SURVIVOR_WORKDIR}"

# Family 2
ids=($G1 $G2 $G3)
## construct the locations of the input files
file_patterns=( "${ids[@]/%/.combined.genotyped.vcf}")
file_patterns=( "${file_patterns[@]/#/${SUPP3DIR}/SS400}")

#echo "File patterns"
#printf '%s\n' "${file_patterns[@]}"

${SURVIVOR} merge <(printf '%s\n' "${file_patterns[@]}") 1000 1 1 0 0 30 \
        sample_files_family2.vcf
${SURVIVOR_ANT} -i sample_files_family2.vcf \
        -b  ${GENECODE_BED} \
        -o sample_merged_annotated_family2.vcf


# Family 3
ids=($F1 $F2 $F3 $F4)
## construct the locations of the input files
file_patterns=( "${ids[@]/%/.combined.genotyped.vcf}")
file_patterns=( "${file_patterns[@]/#/${SUPP3DIR}/SS400}")

${SURVIVOR} merge <(printf '%s\n' "${file_patterns[@]}") 1000 1 1 0 0 30 \
        sample_files_family3.vcf
${SURVIVOR_ANT} -i sample_files_family3.vcf \
        -b  ${GENECODE_BED} \
        -o sample_merged_annotated_family3.vcf
