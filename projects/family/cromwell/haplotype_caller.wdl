task HaplotypeCallerERCPerChr {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  String chr
  File input_bam
  File input_bam_index

  command {
    java -jar -Xmx3G ${GATK} \
      -T HaplotypeCaller \
      -ERC GVCF \
      --variant_index_type LINEAR \
      --variant_index_parameter 128000 \
      -R ${ref_fasta} \
      -I ${input_bam} \
      -L ${chr} \
      -o raw.likelihood.g.vcf.gz
  }
  output {
    File gvcf = "raw.likelihood.g.vcf.gz"
  } 
  runtime {
    rt_mem: "4gb"
    rt_walltime: "15:00:00"
  }
}

task GatherGVCFs {
  Array[File] input_gvcfs
  String sample_name
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  
  command {
    java -cp ${GATK} org.broadinstitute.gatk.tools.CatVariants \
    -R ${ref_fasta} \
    ${sep="-V " input_gvcfs} \
    -out "${sample_name}.g.vcf.gz"
  }
  output {
    File combined_gvcf_file = "${sample_name}.g.vcf.gz"
  }
  runtime {
    rt_mem: "8gb"
    rt_walltime: "3:00:00"
  }
}

workflow CreateGVCF {
  String sample_name
  String input_bam
  Array[String] chromosomes

  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  File input_bam_index


  scatter(chr in chromosomes) {
    call HaplotypeCallerERCPerChr {
      input: chr=chr, 
             input_bam=input_bam,
             input_bam_index=input_bam_index,
             GATK=GATK,
             ref_fasta=ref_fasta,
             ref_fasta_index=ref_fasta_index,
             ref_dict=ref_dict
    }
  }
  call GatherGVCFs {
    input: sample_name=sample_name, 
           input_gvcfs=HaplotypeCallerERCPerChr.gvcf,
           GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict
  }
} 


