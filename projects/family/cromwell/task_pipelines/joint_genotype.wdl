## Tasks to joint genotype GVCF files and filtering

# Combine all the gvcf files into one
task CombineGVCFs {

  # FIXME: We can speed this up with scatter/gather by making it a sub workflow. 
  # https://gatkforums.broadinstitute.org/gatk/discussion/5469/how-to-speed-up-combinegvcfs-seems-unfeasibly-slow
  #for chrom in $all_chroms; do
  #  WKDIR=$(mktemp -d)
  #  for fn in $file_list; do
  #    GATK -T SelectVariants -V $fn -o $WKDIR/$chr.$fn -L $chr
  #    # OR: tabix -h $fn $chr > $WKDIR/$chr.$fn.vcf
  #  done
  #
  #  GATK -T CombineGVCFs -V $WKDIR/$chr.* -o chrom_$chr.vcf.gz
  #  rm -rf $WKDIR
  #done
  #
  #GATK -T CombineVariants -V chrom_*.vcf.gz -o final_gvcf.vcf.gz \
  #    --assumeIdenticalSamples -genotypeMergeOptions UNSORTED 
  

  Array[File] input_gvcfs

  String GATK4
  String ref_fasta

  String output_file_name = "combined.g.vcf"

  command {
    module load java

    ${GATK4} CombineGVCFs \
      --reference  ${ref_fasta} \
      --variant ${sep=" --variant " input_gvcfs} \
      --output ${output_file_name}
  }

  output {
    File combined_gvcf_file = "${output_file_name}"
  }

  runtime {
    rt_nodes: 1
    rt_ppn: 2
    rt_mem: "16gb"
    rt_walltime: "02:23:00:00"
  }

} 

# Joint Genotype
task JointGenotype {

  File combined_gvcf_file

  String GATK4
  String ref_fasta

  String output_file_name = "allsamples.raw.vcf"

  command {
    module load java

    ${GATK4} GenotypeGVCFs \
      --reference  ${ref_fasta} \
      --variant ${combined_gvcf_file} \
      --output ${output_file_name}
  }

  output {
    File genotyped_raw_vcf_file = "${output_file_name}"
  }

  runtime {
    rt_nodes: 1
    rt_ppn: 4
    rt_mem: "32gb"
    rt_walltime: "02:00:00:00"
  }

}

# Filtering

#Extract and Filter SNPS
task ExtractandFilterSNPs {

  File genotyped_raw_vcf_file

  String GATK4
  String ref_fasta

  String output_file_name = "allsamples.filteredsnps.vcf"

  command {
    module load java

    # Extract SNPs
    ${GATK4} SelectVariants \
      --reference "${ref_fasta}" \
      --variant "${genotyped_raw_vcf_file}" \
      --select-type-to-include SNP \
      --output allsamples.rawsnps.vcf

    # Filter SNPs
    ${GATK4} VariantFiltration \
      --reference "${ref_fasta}" \
      --variant allsamples.rawsnps.vcf \
      --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
      --filter-name "snps_filter_1" \
      --output ${output_file_name}
  }

  output {
    File filtered_snps_vcf = "${output_file_name}"
  }

  runtime {
    rt_nodes: 1
    rt_ppn: 4
    rt_mem: "32gb"
    rt_walltime: "02:00:00:00"
  }

}


# Extract and Filter Indels
task ExtractandFilterINDELs {

  File genotyped_raw_vcf_file

  String GATK4
  String ref_fasta

  String output_file_name = "allsamples.filteredindels.vcf"

  command {
    module load java

    # Extract Indels
    ${GATK4} SelectVariants \
      --reference "${ref_fasta}" \
      --variant "${genotyped_raw_vcf_file}" \
      --select-type-to-include INDEL \
      --output allsamples.rawindels.vcf

    # Filter INDELs
    ${GATK4} VariantFiltration \
      --reference "${ref_fasta}" \
      --variant allsamples.rawindels.vcf \
      --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" \
      --filter-name "indel_filter_1"  \
      --output ${output_file_name}
  }

  output {
    File filtered_indels_vcf = "${output_file_name}"
  }

  runtime {
    rt_nodes: 1
    rt_ppn: 4
    rt_mem: "32gb"
    rt_walltime: "02:00:00:00"
  }

}

# Combine filtered SNPS/Indels
task CombineFilteredSNPsIndels {

  File filtered_snps_vcf
  File filtered_indels_vcf

  String GATK4
  String ref_fasta

  String output_file_name = "allsamples.filtered.vcf"

  command {
    module load java

    # Combine filtered SNPS/Indels
    ${GATK4} MergeVcfs \
      --INPUT "${filtered_snps_vcf}" \
      --INPUT "${filtered_indels_vcf}" \
      --OUTPUT "${output_file_name}"
  }

  output {
    File filtered_vcf = "${output_file_name}"
  }

  runtime {
    rt_nodes: 1
    rt_ppn: 4
    rt_mem: "32gb"
    rt_walltime: "02:00:00:00"
  }
}

# VQSR 
task ApplyVQSR {

  File filtered_vcf

  String GATK4
  String VCFTOOLS
  String ref_fasta

  String output_file_name = "allsamples.filtered.recal.snp.indels.allelereduction.VQSR.recode.vcf"

  String VQSRFILTERLEVEL="99.9"
  String VQSRargsSNP=" -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 -an QD -an DP -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR --max-gaussians 5 "
  String VQSRresourcesSNP=" -resource hapmap,known=false,training=true,truth=true,prior=15.0:/projects/b1049/genetics_refs/new_2018_bbustos/hapmap_3.3.b37.vcf -resource omni,known=false,training=true,truth=true,prior=12.0:/projects/b1049/genetics_refs/new_2018_bbustos/1000G_omni2.5.b37.vcf -resource 1000G,known=false,training=true,truth=false,prior=10.0:/projects/b1049/genetics_refs/new_2018_bbustos/1000G_phase1.snps.high_confidence.b37.vcf -resource dbsnp,known=true,training=false,truth=false,prior=2.0:/projects/b1049/genetics_refs/new_2018_bbustos/dbsnp_138.b37.vcf"
  String VQSRargsINDEL=" -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --max-gaussians 4 -an QD -an DP -an FS -an SOR -an ReadPosRankSum -an MQRankSum "
  String VQSRresourcesINDEL="-resource mills,known=false,training=true,truth=true,prior=12.0:/projects/b1049/genetics_refs/new_2018_bbustos/Mills_and_1000G_gold_standard.indels.b37.vcf -resource dbsnp,known=true,training=false,truth=false,prior=2.0:/projects/b1049/genetics_refs/new_2018_bbustos/dbsnp_138.b37.vcf"

  command {
    #VARIANT QUALITY SCORE RECALIBRATION - check tranch filter levels
    # load R
    module load java
    module load R

    #VQSR Step 1 [VariantRecalibrator] - SNPs
    ${GATK4} VariantRecalibrator \
      --reference ${ref_fasta} \
      --variant ${filtered_vcf} \
      -mode SNP \
      -O SNP.recal \
      --tranches-file SNP.tranches \
      --rscript-file SNP.plots.R \
      ${VQSRargsSNP} \
      ${VQSRresourcesSNP}

    #VQSR Step 2 [ApplyRecalibration] - SNPs
    ${GATK4} ApplyVQSR \
      --reference ${ref_fasta} \
      -mode SNP \
      --truth-sensitivity-filter-level \
      ${VQSRFILTERLEVEL} \
      --variant ${filtered_vcf} \
      --tranches-file SNP.tranches \
      --recal-file SNP.recal \
      -O allsamples.filtered.recal.snps.vcf

    #VQSR Step 3 [VariantRecalibrator] - INDELs
    ${GATK4} VariantRecalibrator \
      --reference ${ref_fasta} \
      --variant allsamples.filtered.recal.snps.vcf \
      -mode INDEL \
      -O INDEL.recal \
      --tranches-file INDEL.tranches \
      --rscript-file INDEL.plots.R \
      ${VQSRargsINDEL} \
      ${VQSRresourcesINDEL} 

    #VQSR Step 4 [ApplyRecalibration] - INDELs
    ${GATK4} ApplyVQSR \
      --reference ${ref_fasta} \
      -mode INDEL \
      --truth-sensitivity-filter-level ${VQSRFILTERLEVEL} \
      --variant allsamples.filtered.recal.snps.vcf \
      --tranches-file INDEL.tranches \
      --recal-file INDEL.recal \
      -O allsamples.filtered.recal.snpsindels.vcf 

    #Let's flag variants with too many alleles #I typically use 8 as a cutoff?
    ${VCFTOOLS} \
      --vcf allsamples.filtered.recal.snpsindels.vcf \
      --max-alleles 8 \
      --recode \
      --recode-INFO-all \
      --out allsamples.filtered.recal.snps.indels.allelereduction

    #Index resulting VCF
    ${GATK4} IndexFeatureFile \
      -F allsamples.filtered.recal.snps.indels.allelereduction.recode.vcf

    #Let's flag variant that fail our VQSR filtering, and produce our final VCF file
    ${GATK4} SelectVariants \
      --reference ${ref_fasta} \
      --variant allsamples.filtered.recal.snps.indels.allelereduction.recode.vcf \
      -O allsamples.filtered.recal.snp.indels.allelereduction.VQSR.recode.vcf

  }

  output {
    File vqsr_output_vcf = "${output_file_name}"
  }

  runtime {
    rt_nodes: 1
    rt_ppn: 4
    rt_mem: "32gb"
    rt_walltime: "02:00:00:00"
  }

}
