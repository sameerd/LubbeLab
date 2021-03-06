#!/bin/bash

cwd=`pwd`
queue=genomics
allocation=b1042
walltime="02:00:00:00"
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
module load vcftools/current
module load samtools

cd data/output

parallel bgzip {} ::: *.vcf
parallel tabix -p vcf {} ::: *.vcf.gz


EOJ
