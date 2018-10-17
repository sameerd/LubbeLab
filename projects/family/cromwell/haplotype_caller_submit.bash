#!/bin/bash

set -x

# List of SS ID's to process to gvcfs
declare -a IDS=( "SS4009017" "SS4009018" "SS4009019" "SS4009020" "SS4009022" "SS4009030" )

# assuming this script gets run from the scripts directory
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
#!/bin/bash

module load java

java -Dconfig.file=cromwell/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-34.jar \
     run -i cromwell/inputs/haplotype_caller_${ID}.json \
     cromwell/haplotype_caller.wdl

EOJ

done

