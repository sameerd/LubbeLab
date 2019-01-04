#!/bin/bash

cwd=`pwd`
queue=genomicslong
allocation=b1042
walltime="06:00:00:00"

msub \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q ${queue} \
  -l walltime=${walltime} \
  -l nodes=1:ppn=6 \
  -l mem=30gb \
  -A ${allocation} \
  - <<EOJ

#!/bin/bash

module load bcftools

# create list of files to merge 
ls data/output/*.bcf > data/ppmi_merge.list

bcftools merge --file-list data/ppmi_merge.list > data/input/ppmi/wgs_merged.vcf

EOJ
