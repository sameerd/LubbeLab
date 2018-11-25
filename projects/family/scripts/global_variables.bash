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
MERLIN="${PROGRAMSDIR}/merlin_src/merlin-1.1.2/executables/merlin"
PEDSTATS="${PROGRAMSDIR}/merlin_src/merlin-1.1.2/executables/pedstats"

BEAGLE_5_0="${PROGRAMSDIR}/beagle/beagle.10Sep18.879.jar"
BEAGLE_BREF3_DIR="${PROGRAMSDIR}/beagle/bref3"
BEAGLE_GENETIC_MAP_DIR="${PROGRAMSDIR}/beagle/genetic_maps"
REFINED_IBD="${PROGRAMSDIR}/beagle/refined-ibd.12Jul18.a0b.jar"
IBDSEQ="${PROGRAMSDIR}/beagle/ibdseq.r1206.jar"
KING="${PROGRAMSDIR}/king/king"
PLINK="${PROGRAMSDIR}/plink_feb2018/plink"
MERGE_IBD="${PROGRAMSDIR}/beagle/merge-ibd-segments.12Jul18.a0b.jar"



ANNOVARDIR="${PROGRAMSDIR}/annovar_2017/annovar"
ANNOVAR_CONVERT="${ANNOVARDIR}/convert2annovar.pl"
ANNOVAR_TABLE="${ANNOVARDIR}/table_annovar.pl"

# These are the references
B37_to_HG19_CHAIN="${REFSDIR}/chain_files/b37tohg19.chain"

GENOMEREF_37="${REFSDIR}/fasta/human_g1k_v37.fasta"
GENOMEREF_37_DICT="${GENOMEREF_37%.*}".dict


JAVA=java



