#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

module load java

${JAVA} -jar ${PICARD} ValidateSamFile \
    I=data/input/bams/SS4009016_sorted_unique.bam \
    MODE=SUMMARY

