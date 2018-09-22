#!/bin/bash

#MSUB -A b1042
#MSUB -e logs/errlog.dat
#MSUB -o logs/outlog.dat
#MSUB -q genomics
#MSUB -l walltime=18:00:00
#MSUB -l nodes=1:ppn=2

set -x

# Set your working directory
# Required for quest
if [[ -v PBS_O_WORKDIR ]]; then cd $PBS_O_WORKDIR; fi

module load java

java -Dconfig.file=cromwell/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-34.jar \
     run -i cromwell/inputs.json cromwell/haplotype_caller.wdl

