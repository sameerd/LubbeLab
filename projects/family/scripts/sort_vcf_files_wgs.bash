#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

module load java

${JAVA} -jar ${PICARD} LiftoverVcf \
    I="${WGS_BB_PIPELINE_VCF}"\
    O="${PRE_GEN_VCF_SORTED}" \
    CHAIN="${B37_to_HG19_CHAIN}" \
    REJECT="${PRE_GEN_VCF_REJECTED}" \
    R="${GENOMEREF}"


