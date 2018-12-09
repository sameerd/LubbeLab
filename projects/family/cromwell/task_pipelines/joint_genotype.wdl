## Tasks to joint genotype GVCF files and filtering

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

} 
