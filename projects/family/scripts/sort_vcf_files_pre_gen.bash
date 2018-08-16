#!/bin/bash

#MSUB -A b1049
#MSUB -e logs/errlog.dat
#MSUB -o logs/outlog.dat

set -x

# Set your working directory
# Required for quest
if [[ -v PBS_O_WORKDIR ]]; then cd $PBS_O_WORKDIR; fi

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

module load java

${JAVA} -jar ${PICARD} LiftoverVcf \
    I="${PRE_GEN_VCF}"\
    O="${PRE_GEN_VCF_SORTED}" \
    CHAIN="${B37_to_HG19_CHAIN}" \
    REJECT="${PRE_GEN_VCF_REJECTED}" \
    R="${GENOMEREF}"

#${JAVA} -jar ${PICARD} SortVcf \
#    I="${PRE_GEN_VCF}"\
#    O="${PRE_GEN_VCF_SORTED}" \
#    SEQUENCE_DICTIONARY="${GENOMEREF_37_DICT}"

#GATK complains about idx if we don't delete this
#rm ${PRE_GEN_VCF_SORTED%.*}.idx
