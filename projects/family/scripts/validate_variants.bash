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

# Try deleting the index files if GATK complains that the contigs
# are not in lexicographic order
${JAVA} -jar ${GATK} \
   -T ValidateVariants \
   -R ${GENOMEREF} \
   --variant ${P1_SORTED} 

