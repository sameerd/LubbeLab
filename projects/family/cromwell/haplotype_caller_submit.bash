#!/bin/bash

declare -a IDS=( "SS4009017" "SS4009018" "SS4009019" "SS4009020" "SS4009022" "SS4009030" )

set -x


# assuming this gets set from the scripts directory
cwd=`pwd`


for ID in "${IDS[@]}"
do
  echo "Submitting haplotype_caller job for ${ID}" 


  msub -A b1042 \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q genomics \
  -l walltime=30:00:00 \
  -l nodes=1:ppn=2 \
  - <<EOJ

module load java

java -Dconfig.file=cromwell/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-34.jar \
     run -i cromwell/haplotype_caller_inputs/haplotype_caller_${ID}.json \
     cromwell/haplotype_caller.wdl

EOJ

done

