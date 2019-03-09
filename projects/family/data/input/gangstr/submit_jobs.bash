#!/bin/bash

# NOTE: run this file from the output directory and not the base directory

myids="SS4009013 SS4009014 SS4009015 SS4009016 SS4009017 SS4009018 SS4009019 SS4009020 SS4009021 SS4009023 SS4009030"

# create and empty jobs directory
mkdir -p jobs
rm -f jobs/*

cwd=`pwd`

for id in $myids;
do
  
  # create job script. We do not use process redirection here
  # because the jobs sometimes timeout and become zombie processes
  # Not sure if even this fixes it.
  cat <<EOJ  >> jobs/"$id".sh
#!/bin/bash

/projects/b1049/genetics_programs/gangSTR/GangSTR-2.3/bin/GangSTR \
      --bam ../bams/${id}_sorted_unique.bam \
      --ref /projects/b1049/genetics_refs/fasta/human_g1k_v37.fasta \
      --regions /projects/b1049/genetics_programs/gangSTR/reference/hs37_ver13.bed \
      --frrweight 0.25 --enclweight 1.0 --spanweight 1.0 --flankweight 1.0 \
      --ploidy 2 --numbstrap 50 --minmatch 5 --minscore 80 \
      --out ${id}


# Wait for dumpSTR dockerhub to update before using this
#module load singularity
#singularity run \
#  /projects/b1049/genetics_programs/gangSTR/str-toolkit_latest.sif \
#  dumpSTR \
#    --vcf ${id}.vcf \
#    --out ${id}.filtered \
#    --max-call-DP 1000 \
#    --filter-spanbound-only \
#    --filter-badCI      \
#    --filter-regions /STRTools/dumpSTR/filter_files/hs37_segmentalduplications.bed.gz \
#    --filter-regions-names SEGDUP 

# filtering with manual installation
module load anaconda3

PYTHONPATH=/projects/b1049/genetics_programs/gangSTR/lib/python3.7/site-packages/ \
PATH=\${PATH}:/projects/b1049/genetics_programs/gangSTR/bin \
  dumpSTR \
    --vcf ${id}.vcf \
    --out ${id}.filtered \
    --max-call-DP 1000 \
    --filter-spanbound-only \
    --filter-badCI      \
    --filter-regions /projects/b1049/genetics_programs/gangSTR/STRTools/dumpSTR/filter_files/hs37_segmentalduplications.bed.gz \
    --filter-regions-names SEGDUP 

EOJ

  # submit the newly created job
  msub -A b1042 \
  -e jobs/errlog."$id".txt \
  -o jobs/outlog."$id".txt \
  -d "$cwd" \
  -q genomics \
  -l walltime=14:00:00 \
  -l nodes=1:ppn=2 \
  jobs/"$id".sh

done


