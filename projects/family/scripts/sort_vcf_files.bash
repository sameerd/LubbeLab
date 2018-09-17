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

for filename in "${INPUTDIR}"/*.Cleaned_SNPIndel.vcf; do
  
  fbname=$(basename "${filename}") # basename of file

  # Do not Sort if we have already sorted
  [ -e "${fbname}" ] && continue
  
  ${JAVA} -jar ${PICARD} SortVcf \
    I="${filename}"\
    O="${WORKINGDIR}/${fbname}_Sorted.vcf" \
    SEQUENCE_DICTIONARY="${GENOMEREF_DICT}"
done
