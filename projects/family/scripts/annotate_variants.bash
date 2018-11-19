#!/bin/bash

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

# Annotate the variants file

${ANNOVAR_CONVERT} -format vcf4 \
        "${MERGED_VCF}" \
        -allsample -withfreq \
        -includeinfo \
        -outfile "${ANNOVAR_INPUT}"


# -protocol refGene,genomicSuperDups,gnomad_genome,esp6500siv2_all,cadd13gt20,dbnsfp33a,cg69,exac03,1000g2015aug_all,avsnp150,clinvar_20170905 \
# -operation g,r,f,f,f,f,f,f,f,f,f \

# Convert to Annovar Table
${ANNOVAR_TABLE} "${ANNOVAR_INPUT}" \
        "${ANNOVARDIR}/humandb/" -buildver hg19 \
        -protocol refGene,genomicSuperDups,gnomad_genome,gnomad_exome,cadd13gt10 \
        -operation g,r,f,f,f \
        -remove -otherinfo -nastring .
