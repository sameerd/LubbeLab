## Tasks to joint genotype GVCF files and filtering

# Combine all the gvcf files into one
task CombineGVCFs {

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
    rt_mem: "32gb"
    rt_walltime: "02:00:00"
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
    rt_mem: "32gb"
    rt_walltime: "02:00:00"
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
    rt_mem: "32gb"
    rt_walltime: "02:00:00"
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
      --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" 
      --filter-name "indel_filter_1" 
      --output ${output_file_name}
  }

  output {
    File filtered_indels_vcf = "${output_file_name}"
  }

  runtime {
    rt_mem: "32gb"
    rt_walltime: "02:00:00"
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
      --reference "${ref_fasta}" \
      --INPUT "${filtered_snps_vcf}" \
      --INPUT "${filtered_indels_vcf}" \
      --OUTPUT "${output_file_name}"
  }

  output {
    File filtered_vcf = "${output_file_name}"
  }

  runtime {
    rt_mem: "32gb"
    rt_walltime: "02:00:00"
  }


}
