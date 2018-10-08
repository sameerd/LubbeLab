#!/bin/bash

set -x

# assuming this script gets run from the scripts directory
cwd=`pwd`

msub -A b1042 \
-e "${cwd}/logs/errlog.txt" \
-o "${cwd}/logs/outlog.txt" \
-d "${cwd}" \
-q genomicslong \
-l walltime=72:00:00 \
-l nodes=1:ppn=2 \
- <<EOJ
#!/bin/bash

module load java

java -DLOG_LEVEL=DEBUG -Dconfig.file=cromwell/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-35.jar \
     run -i cromwell/joint_genotype_inputs/input.json \
     cromwell/joint_genotype.wdl

EOJ


