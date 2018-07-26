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


# vc.getGenotype(\"${P1_SAMPLE}\").isHet() && 
# vc.getGenotype(\"${P2_SAMPLE}\").isHet() &&
# vc.getGenotype(\"${C1_SAMPLE}\").isHom() &&
# vc.getGenotype(\"${C2_SAMPLE}\").isHom() &&

${JAVA} -jar ${GATK} \
   -T SelectVariants \
   -R ${GENOMEREF} \
   --variant ${INTERSECTION_VCF} \
   -restrictAllelesTo BIALLELIC \
   -o ${OUTPUT_VCF} \
   -select "vc.getGenotype(\"${P1_SAMPLE}\").isHet() && 
 vc.getGenotype(\"${P2_SAMPLE}\").isHet() && vc.getGenotype(\"${C1_SAMPLE}\").isHom() && vc.getGenotype(\"${C2_SAMPLE}\").isHom()"


# Different approach: Using Picard's FilterVcf tools
#${JAVA} -jar ${PICARD} FilterVcf \
#  I="${COMBINED_VCF}" \
#  O="${OUTPUT_VCF}"  \
#  JS="${VARIANTFILTER_JS}"

