#!/bin/bash

set -x

cwd=`pwd`

cromwell_dir="../../../cromwell"

msub -A b1042 \
  -e "${cwd}/errlog.txt" \
  -o "${cwd}/outlog.txt" \
  -d "${cwd}" \
  -q genomics \
  -l mem=4gb \
  -l walltime=48:00:00 \
  -l nodes=1:ppn=1 \
  - <<EOJ

#!/bin/bash

module load java

java -Dconfig.file=$cromwell_dir/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-35.jar \
     run -i alignment_pipeline.json \
     $cromwell_dir/alignment_pipeline.wdl


EOJ

