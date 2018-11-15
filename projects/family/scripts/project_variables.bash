#!/bin/bash


BASEDIR="/projects/b1049/sameer/LubbeLab/projects/family"

DATADIR="${BASEDIR}/data"

INPUTDIR="${DATADIR}/input"
WORKINGDIR="${DATADIR}/working"
OUTPUTDIR="${DATADIR}/output"

GENOMEREF="${WORKINGDIR}/hg19.fa"
GENOMEREF_DICT="${GENOMEREF%.*}".dict


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

# FAMILY3
F1=9014
F2=9015
F3=9013
F4=9016

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

G1_SORTED="${WORKINGDIR}/${G1}.Cleaned_SNPIndel_Sorted.vcf"
G2_SORTED="${WORKINGDIR}/${G2}.Cleaned_SNPIndel_Sorted.vcf"
G3_SORTED="${WORKINGDIR}/${G3}.Cleaned_SNPIndel_Sorted.vcf"

G1_BAM_READY="${INPUTDIR}/bams/SS400${G1}_sorted_unique_realigned.bam"
G1_G_VCF="${WORKINGDIR}/${G1}.g.vcf"
G2_BAM_READY="${INPUTDIR}/bams/SS400${G2}_sorted_unique_realigned.bam"
G2_G_VCF="${WORKINGDIR}/${G2}.g.vcf"
G3_BAM_READY="${INPUTDIR}/bams/SS400${G3}_sorted_unique_realigned.bam"
G3_G_VCF="${WORKINGDIR}/${G3}.g.vcf"


P1_ANNO="${P1_SORTED}.txt"
P2_ANNO="${P2_SORTED}.txt"
C1_ANNO="${C1_SORTED}.txt"
C2_ANNO="${C2_SORTED}.txt"

MERGED_VCF="${WORKINGDIR}/merged.vcf"
MERGED2_VCF="${WORKINGDIR}/merged2.vcf"
MERGE_PHASED="${WORKINGDIR}/merged_phased.vcf"
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

BEAGLE_OUTPUT_DIR="${WORKINGDIR}/beagle_output"

PRE_GEN_VCF="${INPUTDIR}/NM_SS400_EXOMEonly_02102017_EXOME_SNP.recal.snps.indel_VQSR_hardFiltered.vcf_alleleReduction.vcf.recode.vcf"
PRE_GEN_VCF_ANNO="${PRE_GEN_VCF}.avinput.hg19_multianno.txt"
PRE_GEN_VCF_ID="${WORKINGDIR}/pre_gen_id.vcf"
PRE_GEN_EXONIC_SNP="${WORKINGDIR}/pre_gen_exonic_snp.txt"
PRE_GEN_VCF_SORTED="${WORKINGDIR}/all_vcf_sorted.vcf"
PRE_GEN_VCF_SORTED_QC="${WORKINGDIR}/all_vcf_sorted_qc.vcf"
PRE_GEN_VCF_REJECTED="${WORKINGDIR}/all_vcf_rejected.vcf"

WGS_ALL_VCF="${INPUTDIR}/out.vcf.gz"
WGS_ALL_FILTERED_VCF="${WORKINGDIR}/wgs_all_filtered.vcf"
WGS_ALL_FILTERED_VCF_hg19="${WORKINGDIR}/wgs_all_filtered_hg19.vcf"
WGS_ALL_FILTERED_VCF_REJECTED="${WORKINGDIR}/wgs_all_filtered_rejected.vcf"
WGS_ANNOVAR_INPUT="${WORKINGDIR}/wgs_annovar.avinput"
WGS_ANNOVAR_OUTPUT="${ANNOVAR_INPUT}.hg19_multianno.txt"

WGS_FAM2_VCF="${WORKINGDIR}/wgs_family2_hg19.vcf"

SNP_CHIP_INPUT="${WORKINGDIR}"/CytoSNP-850Kv1-2_iScan_B1.csv
SNP_CHIP_VARIANTS="${WORKINGDIR}"/cytosnp_variants.txt
SNP_CHIP_INTERVALS="${WORKINGDIR}"/intervals.list
SNP_CHIP_VCF="${WORKINGDIR}"/snp_variants.vcf

PLINK_OUTPUT="${WORKINGDIR}"/output.plink

