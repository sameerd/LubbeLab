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

##first need to load the correct version of java (v2.8)
module load java

${JAVA} -jar ${GATK} \
   -T SelectVariants \
   -R ${GENOMEREF} \
   --variant ${MERGED_VCF} \
   -restrictAllelesTo BIALLELIC \
   -o ${INTERSECTION_VCF} \
   -select "set == \"Intersection\""

