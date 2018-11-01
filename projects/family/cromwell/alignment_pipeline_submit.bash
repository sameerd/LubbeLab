#!/bin/bash

set -x

cwd=`pwd`

msub -A b1042 \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q genomics \
  -l walltime=48:00:00 \
  -l nodes=1:ppn=2 \
  - <<EOJ
#!/bin/bash

module load java

java -Dconfig.file=cromwell/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-35.jar \
     run -i cromwell/inputs/alignment_pipeline.json \
     cromwell/alignment_pipeline.wdl

EOJ
