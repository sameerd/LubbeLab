
task haplotype_caller_erc {
  #File GATK
  #File ref_fasta 
  #File ref_fasta_index
  #File ref_dict
  String sample_name
  File input_bam
  #File input_bam_index

  #command {
  #  java -jar ${GATK} \
  #    -T HaplotypeCaller \
  #    -ERC GVCF \
  #    -R ${ref_fasta} \
  #    -I ${input_bam} \
  #    -L 21 \
  #    -o ${sample_name}.raw.likelihood.g.vcf
  #}
  command {
    wc -l ${input_bam} > ${sample_name}.raw.likelihood.g.vcf
  }
  output {
    File GVCF = "${sample_name}.raw.likelihood.g.vcf"
  } 
}


workflow create_gvcf {
  call haplotype_caller_erc 
} 


