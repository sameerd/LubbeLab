#!/bin/bash

set -x

cwd=`pwd`
cromwell_dir="../../cromwell"

sbatch -A b1042 \
  --error "${cwd}/logs/errlog_parliament.txt" \
  --output "${cwd}/logs/outlog_parliament.txt" \
  -D "${cwd}" \
  --partition genomics \
  --mem=4000 \
  -t 48:00:00 \
  -N 1 -n 1 \
<<EOJ
#!/bin/bash

module load java

java -Dconfig.file=$cromwell_dir/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-35.jar \
     run -i cromwell/inputs/parliament2.json \
     $cromwell_dir/parliament2_pipeline.wdl

EOJ
