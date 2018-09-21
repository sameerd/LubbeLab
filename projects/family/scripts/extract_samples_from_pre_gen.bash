#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

##first need to load the correct version of java (v2.8)
module load java

# FIXME: Need to remove idx files before running combine variants

#${JAVA} -jar ${GATK} \
#   -T SelectVariants \
#   -R "${GENOMEREF_37}" \
#   -V "${PRE_GEN_VCF_SORTED}" \
#   -o "${MERGED2_VCF}" \
#   -sn "SS400${C1}" \
#   -sn "SS400${P1}" \
#   -sn "SS400${P2}" \
#   -sn "SS400${C2}" 

# Using GATK4 because of a bug in gatk3

${GATK4} SelectVariants \
   -R "${GENOMEREF}" \
   -V "${PRE_GEN_VCF_SORTED}" \
   -O "${MERGED2_VCF}" \
   --remove-unused-alternates true \
   -sn "SS400${C1}" \
   -sn "SS400${P1}" \
   -sn "SS400${P2}" \
   -sn "SS400${C2}" 




