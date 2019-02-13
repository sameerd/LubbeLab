#!/bin/bash

set -x

cwd=`pwd`

cromwell_dir="../../../cromwell"

# to use spark version
spark="_spark"
# to use non spark version
spark=""

msub -A b1042 \
  -e "${cwd}/errlog.txt" \
  -o "${cwd}/outlog.txt" \
  -d "${cwd}" \
  -q genomics \
  -l walltime=48:00:00 \
  -l nodes=1:ppn=1 \
  - <<EOJ
#!/bin/bash

module load java

java -Dconfig.file=$cromwell_dir/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-35.jar \
     run -i haplotype_caller${spark}.json \
     $cromwell_dir/haplotype_caller${spark}_pipeline.wdl

EOJ

