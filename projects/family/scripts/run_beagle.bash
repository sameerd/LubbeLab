#!/bin/bash

#MSUB -A b1049
#MSUB -e logs/errlog.dat
#MSUB -o logs/outlog.dat

#set -x

# Set your working directory
# Required for quest
if [[ -v PBS_O_WORKDIR ]]; then cd $PBS_O_WORKDIR; fi

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

java -jar /projects/b1049/genetics_programs/beagle/beagle.10Sep18.879.jar \
        gt=${PRE_GEN_VCF} ref=data/working/chr1.1kg.phase3.v5a.b37.bref3 \
        out=data/working/beagle_test chrom=1

