#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

##first need to load the correct version of java (v2.8)
module load java

${JAVA} -jar ${GATK} \
   -T SelectVariants \
   -R "${GENOMEREF}" \
   -V "${PRE_GEN_VCF_SORTED}" \
   -o "${MERGED_VCF}" \
   -env -ef \
   -sn "SS400${F1}" \
   -sn "SS400${F2}" \
   -sn "SS400${F3}" \
   -sn "SS400${F4}" 

cp "${MERGED2_VCF}" "${MERGED_VCF}"



