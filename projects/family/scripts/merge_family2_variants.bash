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

# FIXME: Need to remove idx files before running combine variants

${JAVA} -jar ${GATK} \
   -T CombineVariants \
   -R "${GENOMEREF}" \
   -V:G1,vcf "${G1_SORTED}" \
   -V:G2,vcf "${G2_SORTED}" \
   -V:G3,vcf "${G3_SORTED}" \
   -o "${MERGED_VCF}" \
   -genotypeMergeOptions UNIQUIFY \
   -filteredRecordsMergeType KEEP_UNCONDITIONAL



