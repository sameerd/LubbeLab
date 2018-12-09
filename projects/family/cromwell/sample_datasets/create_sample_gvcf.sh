#!/bin/bash

for filename in ../../data/input/old_gvcfs/*.g.vcf.gz
do
  /projects/b1049/genetics_programs/gatk_2018/gatk-4.0.10.0/gatk \
    SelectVariants \
    -R /projects/b1049/genetics_refs/fasta/human_g1k_v37.fasta \
    -V "${filename}" \
    -L 1:1-1000000 -L 2:1-1000000 \
    -O "${filename##*/}"
done

