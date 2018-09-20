#!/bin/bash

#MSUB -A b1049
#MSUB -e /projects/b1049/sameer/LubbeLab/projects/family/logs/errlog.dat
#MSUB -o /projects/b1049/sameer/LubbeLab/projects/family/logs/outlog.dat
#MSUB -q short
#MSUB -l walltime=01:00:00
#MSUB -l nodes=1:ppn=4

set -x

# Set your working directory
# Required for quest
if [[ -v PBS_O_WORKDIR ]]; then cd $PBS_O_WORKDIR; fi

module load java

java -Dconfig.file=scripts/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-34.jar \
     run -i inputs.json scripts/haplotype_caller.wdl

