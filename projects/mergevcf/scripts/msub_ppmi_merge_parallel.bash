#!/bin/bash

cwd=`pwd`
queue=genomics
allocation=b1042
walltime="02:00:00:00"

msub \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q ${queue} \
  -l walltime=${walltime} \
  -l nodes=1:ppn=24 \
  -l mem=110gb \
  -A ${allocation} \
  - <<EOJ

#!/bin/bash

module load parallel
module load bcftools

# create list of files to merge 
ls data/output/*.bcf > data/ppmi_merge.list

# split merge by chromosome
cat data/chromosomes.txt | parallel -j5 bcftools merge --file-list data/ppmi_merge.list -r {} -o data/working/merge.{}.bcf -O b

# gather all the chromosomes into one
cat data/chromosomes.txt | awk '{print "data/working/merge." \$0 ".bcf"}' | xargs bcftools concat -o data/working/merged.vcf -O v


EOJ
