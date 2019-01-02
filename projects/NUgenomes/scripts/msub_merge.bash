#!/bin/bash

cwd=`pwd`
queue=genomicslong
allocation=b1042
walltime="06:00:00:00"
#walltime="20:00"

msub \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q ${queue} \
  -l walltime=${walltime} \
  -l nodes=1:ppn=2 \
  -A ${allocation} \
  - <<EOJ

#!/bin/bash

module load bcftools
module load current

# create list of files to merge 
ls data/output/*.vcf.gz > merge.list

bcftools merge --file-list merge.list > data/input/NUgenomes/merged.vcf

EOJ
