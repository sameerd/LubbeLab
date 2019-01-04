#!/bin/bash

# Annotate the PPMI files to add new INFO fields and then
# convert to bcf format

cwd=`pwd`
queue=genomics
allocation=b1042
walltime="05:00:00"

#queue=short
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
module load bcftools

# Add INFO header and then copy PPMI files to the output directory
parallel bcftools annotate \
  --header-lines data/ppmi_header_lines.txt \
  --output data/output/{/.}.bcf \
  --output-type b {} ::: ./data/input/ppmi/WGS/PPMISI*/*.vcf.gz 


# the parallel command above converts *.vcf.gz to *.vcf.bcf
# move *.vcf.bcf files to *.bcf so we remove the double extension
cd data/output
for filename in *.vcf.bcf;
do
  mv "${file}" "${file%.vcf.bcf}.bcf"

done

EOJ
