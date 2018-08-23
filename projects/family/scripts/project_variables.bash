#!/bin/bash


# Create small data set of just one chromosome
BASEDIR="/projects/b1049/sameer/LubbeLab/projects/family"

DATADIR="${BASEDIR}/data"

INPUTDIR="${DATADIR}/input"
WORKINGDIR="${DATADIR}/working"
OUTPUTDIR="${DATADIR}/output"

GENOMEREF="${WORKINGDIR}/hg19.fa"
GENOMEREF_DICT="${GENOMEREF%.*}".dict

# FIXME: move to global variables and use the ref
GENOMEREF_37="${WORKINGDIR}/human_g1k_v37.fasta"
GENOMEREF_37_DICT="${GENOMEREF_37%.*}".dict

VARIANTFILTER_JS="${BASEDIR}/scripts/variantFilter.js"

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

P1_SAMPLE="${P1}.P1"
P2_SAMPLE="${P2}.P2"
C1_SAMPLE="${C1}.C1"
C2_SAMPLE="${C2}.C2"

P1_INPUT="${INPUTDIR}/${P1}.Cleaned_SNPIndel.vcf"
P2_INPUT="${INPUTDIR}/${P2}.Cleaned_SNPIndel.vcf"
C1_INPUT="${INPUTDIR}/${C1}.Cleaned_SNPIndel.vcf"
C2_INPUT="${INPUTDIR}/${C2}.Cleaned_SNPIndel.vcf"

P1_SORTED="${WORKINGDIR}/${P1}.Cleaned_SNPIndel_Sorted.vcf"
P2_SORTED="${WORKINGDIR}/${P2}.Cleaned_SNPIndel_Sorted.vcf"
C1_SORTED="${WORKINGDIR}/${C1}.Cleaned_SNPIndel_Sorted.vcf"
C2_SORTED="${WORKINGDIR}/${C2}.Cleaned_SNPIndel_Sorted.vcf"

P1_ANNO="${P1_SORTED}.txt"
P2_ANNO="${P2_SORTED}.txt"
C1_ANNO="${C1_SORTED}.txt"
C2_ANNO="${C2_SORTED}.txt"

MERGED_VCF="${WORKINGDIR}/merged.vcf"
MERGED2_VCF="${WORKINGDIR}/merged2.vcf"
INTERSECTION_VCF="${WORKINGDIR}/intersection.vcf"
INTERSECTION_FILTERED_VCF="${WORKINGDIR}/intersection_filtered.vcf"

ANNOVAR_INPUT="${WORKINGDIR}/annovar.avinput"
ANNOVAR_OUTPUT="${ANNOVAR_INPUT}.hg19_multianno.txt"

OUTPUT_VCF="${OUTPUTDIR}/output.vcf"
OUTPUT_VCFTOOLS="${OUTPUTDIR}/output.vcftools"
OUTPUT_TXT="${OUTPUTDIR}/output.txt"
OUTPUT_TXT_SMALL="${OUTPUTDIR}/output.small.txt"
OUTPUT_TXT_SMALLER="${OUTPUTDIR}/output.smaller.txt"
OUTPUT_YCHR="${OUTPUTDIR}/output.chrY.txt"

PRE_GEN_VCF="${INPUTDIR}/NM_SS400_EXOMEonly_02102017_EXOME_SNP.recal.snps.indel_VQSR_hardFiltered.vcf_alleleReduction.vcf.recode.vcf"
PRE_GEN_VCF_SORTED="${WORKINGDIR}/all_vcf_sorted.vcf"
PRE_GEN_VCF_REJECTED="${WORKINGDIR}/all_vcf_rejected.vcf"

SNP_CHIP_INPUT="${WORKINGDIR}"/CytoSNP-850Kv1-2_iScan_B1.csv
SNP_CHIP_VARIANTS="${WORKINGDIR}"/cytosnp_variants.txt
