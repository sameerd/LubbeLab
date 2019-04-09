#!/bin/bash

#run Survivor and Survivor annotation

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

# create a directory for file that are supported by three callers
SUPP3DIR="${SURVIVOR_WORKDIR}/SUPP3"
mkdir -p "${SUPP3DIR}"
cd "${SUPP3DIR}"

# read all the files in the svtyped_vcf directory and extract out all IDs
mapfile -t id_array < <(ls ${PARLIAMENT_INPUTDIR}/svtyped_vcfs/* | grep -oP "SS400[0-9]*" | sort | uniq)
#printf '%s\n' "${id_array[@]}" 

# Merge the various caller results so that we have one file per ID. 
# The default Parliament output gives us the entire results. Here we
# want to ensure that we have atleast three callers per variant in each sample.
for id in "${id_array[@]}"
do
    echo "Processing $id alone"
    ${SURVIVOR} merge \
            <(ls ${PARLIAMENT_INPUTDIR}/svtyped_vcfs/$id*) 1000 3 1 0 0 30 \
            "${SUPP3DIR}/${id}_merged.vcf"
done

# Family 2
ids=($G1 $G2 $G3)
## construct the locations of the input files
file_patterns=( "${ids[@]/%/_merged.vcf}")
file_patterns=( "${file_patterns[@]/#/${SUPP3DIR}/SS400}")

#echo "File patterns"
#printf '%s\n' "${file_patterns[@]}"

${SURVIVOR} merge <(printf '%s\n' "${file_patterns[@]}") 1000 1 1 0 0 30 sample_files_family2.vcf
${SURVIVOR_ANT} -i sample_files_family2.vcf \
        -b  ${GENECODE_BED} \
        -o sample_merged_annotated_family2.vcf


# Family 3
ids=($F1 $F2 $F3 $F4)
## construct the locations of the input files
file_patterns=( "${ids[@]/%/_merged.vcf}")
file_patterns=( "${file_patterns[@]/#/${SUPP3DIR}/SS400}")

${SURVIVOR} merge <(printf '%s\n' "${file_patterns[@]}") 1000 1 1 0 0 30 sample_files_family3.vcf
${SURVIVOR_ANT} -i sample_files_family3.vcf \
        -b  ${GENECODE_BED} \
        -o sample_merged_annotated_family3.vcf
