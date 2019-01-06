#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

module load java

${JAVA} -jar ${PICARD} LiftoverVcf \
    I="${WGS_BB_PIPELINE_VCF}"\
    O="${ALL_VCF_SORTED}" \
    CHAIN="${B37_to_HG19_CHAIN}" \
    REJECT="${ALL_FILTERED_VCF_REJECTED}" \
    R="${GENOMEREF}"


