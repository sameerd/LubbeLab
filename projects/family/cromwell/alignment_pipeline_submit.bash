#!/bin/bash

set -x

cwd=`pwd`


# Set up the INPUT JSON FILE
# FIXME: We will make this customizable later on
read -r -d "" INPUT_FILE <<'EOF'
{
  "alignment_workflow.input_samples_file" : "/projects/b1049/sameer/LubbeLab/projects/family/cromwell/inputs/NM_NGS_samples_fastq.tsv", 
  "alignment_workflow.output_destination_dir" : "/projects/b1042/LubbeLab/sameer/tmp_output"
}
EOF


msub -A b1042 \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q genomics \
  -l walltime=48:00:00 \
  -l nodes=1:ppn=2 \
  - bash <<EOJ
#!/bin/bash

set -x

module load java

java -Dconfig.file=cromwell/cromwell_config.conf \
     -jar /projects/b1049/genetics_programs/cromwell/cromwell-35.jar \
     run -i <( echo '$INPUT_FILE' ) \
     cromwell/alignment_pipeline.wdl

EOJ

