#!/bin/bash

#MSUB -A b1049
#MSUB -e logs/errlog.dat
#MSUB -o logs/outlog.dat

#MSUB -l naccesspolicy=singlenode
#MSUB -l walltime=336:00:00
#MSUB -q genomicsburst


set -x

# Set your working directory
# Required for quest
if [[ -v PBS_O_WORKDIR ]]; then cd $PBS_O_WORKDIR; fi

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

##first need to load the correct version of java (v2.8)
module load java


# Create gvcf files for members of family 2
for (( i = 1; i <= 3; i++ ))
do
  input_var="G${i}_BAM_READY"
  output_var="G${i}_G_VCF"

  ${JAVA} -jar ${GATK} \
    -T HaplotypeCaller \
    -R "${GENOMEREF_37}" \
    --emitRefConfidence GVCF \
    -I ${!input_var} \
    -o ${!output_var}

done

