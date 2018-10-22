#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

module load java

${JAVA} -jar ${GATK} \
    -V "${WGS_ALL_VCF}" \
    -o "${WGS_ALL_FILTERED_VCF}" \
    -T SelectVariants \
    -R "${GENOMEREF_37}" \
    -env \
    -ef 

${JAVA} -jar ${PICARD} LiftoverVcf \
    I="${WGS_ALL_FILTERED_VCF}"\
    O="${WGS_ALL_FILTERED_VCF_hg19}" \
    CHAIN="${B37_to_HG19_CHAIN}" \
    REJECT="${WGS_ALL_FILTERED_VCF_REJECTED}" \
    R="${GENOMEREF}"

