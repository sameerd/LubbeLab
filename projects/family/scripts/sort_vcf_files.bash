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

  output_file="${WORKINGDIR}/${fbname}_Sorted.vcf"

  # Do not Sort if we have already have an output file 
  if [ -e "${output_file}" ]; then 
    continue
  fi
  
  ${JAVA} -jar ${PICARD} SortVcf \
    I="${filename}"\
    O="${output_file}" \
    SEQUENCE_DICTIONARY="${GENOMEREF_DICT}"
done
