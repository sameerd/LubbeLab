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
module load gatk/4.0.4

# JUST for TESTING
# read from list
#parallel -a vcflist.txt gatk --java-options "-Xmx4G" SortVcf --INPUT {} --OUTPUT output/{/.}.sorted.vcf

# read directly from file
parallel gatk --java-options "-Xmx4G" SortVcf --INPUT {} --OUTPUT output/{/.}.sorted.vcf ::: raw/*/*.vcf

EOJ
