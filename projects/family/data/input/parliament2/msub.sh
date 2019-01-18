#!/bin/bash

#MSUB -A b1042
#MSUB -l nodes=1:ppn=24
#MSUB -l walltime=1:00:00:00
#MSUB -q genomics
#MSUB -e errlog
#MSUB -j oe

module load singularity

cd $PBS_O_WORKDIR

make run
