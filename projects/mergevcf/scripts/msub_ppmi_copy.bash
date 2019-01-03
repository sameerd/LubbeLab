#!/bin/bash

# Sort the vcf files with gatk4

cwd=`pwd`
queue=short
allocation=b1042
walltime="04:00:00"
#walltime="20:00"

msub \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q ${queue} \
  -l walltime=${walltime} \
  -l nodes=1:ppn=1 \
  -A ${allocation} \
  - <<EOJ

#!/bin/bash

# Copy files to the output directory
cp -t ./data/output ./data/input/ppmi/WGS/PPMISI*/*.vcf.gz 

EOJ
