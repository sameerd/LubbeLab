#!/bin/bash

PROJECTDIR="/projects/b1049"

PROGRAMSDIR="${PROJECTDIR}/genetics_programs"
REFSDIR="${PROJECTDIR}/genetics_refs"


#These are our resources
SAMTOOLS="${PROGRAMSDIR}/samtools/samtools" 
BCFTOOLS="${PROGRAMSDIR}/bcftools/bcftools"
GATK="${PROGRAMSDIR}/gatk/GenomeAnalysisTK.jar"
GATK4="${PROGRAMSDIR}/gatk_2017/gatk"
PICARD="${PROGRAMSDIR}/picard/picard.jar"
VCFTOOLS="${PROGRAMSDIR}/vcftools/bin/vcftools"
VCFSORT="${PROGRAMSDIR}/vcftools/bin/vcf-sort"

ANNOVARDIR="${PROGRAMSDIR}/annovar_2017/annovar"
ANNOVAR_CONVERT="${ANNOVARDIR}/convert2annovar.pl"
ANNOVAR_TABLE="${ANNOVARDIR}/table_annovar.pl"

# These are the references
B37_to_HG19_CHAIN="${REFSDIR}/chain_files/b37tohg19.chain"

JAVA=java



