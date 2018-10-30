#!/bin/bash

set -x

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


