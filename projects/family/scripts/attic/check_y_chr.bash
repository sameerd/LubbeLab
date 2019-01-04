#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

cat /dev/null > "${OUTPUT_YCHR}"

for filename in "${INPUTDIR}"/*.vcf; do
  [ -e "${filename}" ] || continue

  fbname=$(basename "${filename}") # basename of file
  echo -n "$fbname "   >> "${OUTPUT_YCHR}"
  grep -i "^chrY" ${filename} | wc -l >> "${OUTPUT_YCHR}"
done
