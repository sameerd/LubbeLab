task haplotype_caller_erc_per_chr {
  #File GATK
  #File ref_fasta 
  #File ref_fasta_index
  #File ref_dict
  String chr
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
    wc -l ${input_bam} > raw.likelihood.g.vcf
    echo "${chr}" >> raw.likelihood.g.vcf
  }
  output {
    File gvcf = "raw.likelihood.g.vcf"
  } 
}

task gather_gvcfs {
  Array[File] input_gvcfs
  String sample_name
  
  command {
    cat ${sep=" " input_gvcfs} > "${sample_name}.g.vcf"
  }
  output {
    File combined_gvcf_file = "${sample_name}.g.vcf"
  }
}

workflow create_gvcf {
  String sample_name
  String input_bam
  Array[String] chromosomes
  scatter(chr in chromosomes) {
    call haplotype_caller_erc_per_chr {
      input: chr=chr, input_bam=input_bam
    }
  }
  call gather_gvcfs {
    input: sample_name=sample_name, 
           input_gvcfs=haplotype_caller_erc_per_chr.gvcf
  }
} 


