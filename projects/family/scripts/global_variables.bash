#!/bin/bash

PROJECTDIR="/projects/b1049"

PROGRAMSDIR="${PROJECTDIR}/genetics_programs"


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

JAVA=java



