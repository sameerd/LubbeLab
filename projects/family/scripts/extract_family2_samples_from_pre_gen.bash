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
   -o "${MERGED2_VCF}" \
   -env -ef \
   -sn "SS400${G1}" \
   -sn "SS400${G2}" \
   -sn "SS400${G3}" 





