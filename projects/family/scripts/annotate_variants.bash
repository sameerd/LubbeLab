#!/bin/bash

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

# Annotate the variants file

${ANNOVAR_CONVERT} -format vcf4 \
        "${ALL_VCF_SORTED_QC}" \
        -allsample -withfreq \
        -includeinfo \
        -outfile "${ANNOVAR_INPUT}"

# Convert to Annovar Table
${ANNOVAR_TABLE} "${ANNOVAR_INPUT}" \
        "${ANNOVARDIR}/humandb/" -otherinfo -buildver hg19 \
        -protocol wgEncodeRegTfbsClusteredV3,tfbsConsSites,wgEncodeRegDnaseClusteredV3,RegulomeDB_dbSNP141,refGene,genomicSuperDups,esp6500siv2_all,gnomad_exome,gnomad_genome,dbnsfp33a,cg69,exac03,1000g2015aug_all,clinvar_20170905,avsnp150,cadd13gt10 \
        -operation r,r,r,r,g,r,f,f,f,f,f,f,f,f,f,f \
        -remove -nastring . \
        -thread 20

