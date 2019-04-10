#!/bin/bash

BASEDIR="/projects/b1049/sameer/LubbeLab/projects/family"

DATADIR="${BASEDIR}/data"

INPUTDIR="${DATADIR}/input"
WORKINGDIR="${DATADIR}/working"
OUTPUTDIR="${DATADIR}/output"

GENOMEREF="${WORKINGDIR}/hg19.fa"
GENOMEREF_DICT="${GENOMEREF%.*}".dict


# Family 1
# P's and C's stand for parents and children
P1=9018
P2=9019
C1=9017
C2=9020

# Family 2
# G's stand for generations
G1=9021
G2=9023
G3=9030

# FAMILY3
F1=9014
F2=9015
F3=9013
F4=9016

MERGED_VCF="${WORKINGDIR}/merged.vcf"

ANNOVAR_INPUT="${WORKINGDIR}/annovar.avinput"
ANNOVAR_OUTPUT="${ANNOVAR_INPUT}.hg19_multianno.txt"
ANNOVAR_HEADERS="${WORKINGDIR}/otherinfo.headers.txt"
ANNOVAR_FILTERED="${WORKINGDIR}/annovar.filtered.txt"

BEAGLE_OUTPUT_DIR="${WORKINGDIR}/beagle_output"

PRE_GEN_VCF="${INPUTDIR}/NM_SS400_EXOMEonly_02102017_EXOME_SNP.recal.snps.indel_VQSR_hardFiltered.vcf_alleleReduction.vcf.recode.vcf"
PRE_GEN_VCF_ANNO="${PRE_GEN_VCF}.avinput.hg19_multianno.txt"

WGS_BB_PIPELINE_VCF="${INPUTDIR}/NM_SS400_WGS.processed.vcf"

ALL_VCF_SORTED="${WORKINGDIR}/all_sorted.vcf"
ALL_VCF_SORTED_QC="${WORKINGDIR}/all_sorted_qc.vcf"
ALL_VCF_REJECTED="${WORKINGDIR}/all_rejected.vcf"

ALL_FILTERED_VCF="${WORKINGDIR}/all_filtered.vcf"
ALL_FILTERED_VCF_hg19="${WORKINGDIR}/all_filtered_hg19.vcf"
ALL_FILTERED_VCF_REJECTED="${WORKINGDIR}/all_filtered_rejected.vcf"

PARLIAMENT_INPUTDIR="${INPUTDIR}/parliament2"
SURVIVOR_WORKDIR="${WORKINGDIR}/survivor"
SUPP3DIR="${SURVIVOR_WORKDIR}/SUPP3"



