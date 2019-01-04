#!/bin/bash

# Sort the vcf files with gatk4

cwd=`pwd`
queue=genomics
allocation=b1042
walltime="02:00:00:00"

#queue=short
#walltime="20:00"

msub \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q ${queue} \
  -l walltime=${walltime} \
  -l nodes=1:ppn=24 \
  -A ${allocation} \
  - <<EOJ

#!/bin/bash

module load parallel
module load bcftools

# Add INFO header and then copy PPMI files to the output directory
parallel bcftools annotate \
  --header-lines data/ppmi_header_lines.txt \
  --output data/output/{/} \
  --output-type b {} ::: ./data/input/ppmi/WGS/PPMISI*/*.vcf.gz 

EOJ
