#!/bin/bash

#MSUB -A b1049
#MSUB -e logs/errlog.dat
#MSUB -o logs/outlog.dat

set -x

# Set your working directory
# Required for quest
if [[ -v PBS_O_WORKDIR ]]; then cd $PBS_O_WORKDIR; fi

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

## Create a reference file in the input directory
cd ${WORKINGDIR}
mkdir -p hg19
cd hg19
tar zxf "${PROJECTDIR}/genetics_refs/fasta/chromFa.tar.gz"


cd ${WORKINGDIR}
rm -f hg19.fa hg19.fa.dict hg19.fa.fai
# Look at the first VCF file and read lines till reference
# then grep out fragments
sed '/^##reference=/q' ${P1_INPUT} | \
  grep -Po "(?<=##contig=\<ID=).*(?=,assembly)" | \
  awk '{print "cat hg19/" $1 ".fa >> hg19.fa"}' | bash

module load java

# now create the fasta index file
${SAMTOOLS} faidx hg19.fa
${JAVA} -jar ${PICARD} CreateSequenceDictionary \
  R=${GENOMEREF} \
  O=hg19.dict




