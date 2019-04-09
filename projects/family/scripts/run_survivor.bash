#!/bin/bash

#run Survivor and Survivor annotation

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

mkdir -p "${SURVIVOR_WORKDIR}"
cd "${SURVIVOR_WORKDIR}"

# Family 2
ids=($G1 $G2 $G3)
# construct the locations of the input files
files=( "${ids[@]/%/.sam_sorted_unique.combined.genotyped.vcf}")
files=( "${files[@]/#/${PARLIAMENT_INPUTDIR}/SS400}")
printf '%s\n' "${files[@]}" > sample_files_family2.txt

${SURVIVOR} merge sample_files_family2.txt 1000 2 1 1 0 30 sample_files_family2.vcf
${SURVIVOR_ANT}  -i sample_files_family2.vcf \
        -b  ${GENECODE_BED} \
        -o sample_merged_annotated_family2.vcf


# Family 3
ids=($F1 $F2 $F3 $F4)
# construct the locations of the input files
files=( "${ids[@]/%/.sam_sorted_unique.combined.genotyped.vcf}")
files=( "${files[@]/#/${PARLIAMENT_INPUTDIR}/SS400}")
printf '%s\n' "${files[@]}" > sample_files_family3.txt

${SURVIVOR} merge sample_files_family3.txt 1000 2 1 1 0 30 sample_files_family3.vcf
${SURVIVOR_ANT}  -i sample_files_family3.vcf \
        -b ${GENECODE_BED} \
        -o sample_merged_annotated_family3.vcf

