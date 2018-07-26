#!/bin/bash

PROJECTDIR="/projects/b1049"

PROGRAMSDIR="${PROJECTDIR}/genetics_programs"

#These are our resources
SAMTOOLS="${PROGRAMSDIR}/samtools/samtools" 
GATK="${PROGRAMSDIR}/gatk/GenomeAnalysisTK.jar"
PICARD="${PROGRAMSDIR}/picard/picard.jar"
VCFSORT="${PROGRAMSDIR}/vcftools/bin/vcf-sort"
JAVA=java
