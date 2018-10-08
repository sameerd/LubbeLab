task CombineGVCFsAndJointGenotypePerChr {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  String chr
  Array[File] input_gvcfs
  Array[File] input_gvcfs_index

  command {
    java -jar -Xmx7G ${GATK} \
      -T CombineGVCFs \
      -R ${ref_fasta} \
      -V ${sep=" -V " input_gvcfs} \
      -L ${chr}:1-10000 \
      -o combined.g.vcf.gz

    java -jar -Xmx7G ${GATK} \
      -T GenotypeGVCFs \
      -R ${ref_fasta} \
      -V combined.g.vcf.gz \
      -L ${chr}:1-10000 \
      --includeNonVariantSites \
      -o combined.vcf.gz
  }
  output {
    File vcf = "combined.vcf.gz"
  } 
  runtime {
    rt_mem: "8gb"
    rt_walltime: "1:00:00"
  }
}


task GatherVCFs {
  Array[File] input_vcfs
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  
  command {
    java -cp ${GATK} org.broadinstitute.gatk.tools.CatVariants \
    -R ${ref_fasta} \
    -V ${sep=" -V " input_vcfs} \
    -out out.vcf.gz
  }
  output {
    File combined_vcf_file = "out.vcf.gz"
  }
  runtime {
    rt_mem: "8gb"
    rt_walltime: "1:00:00"
  }
}

workflow CreateJointGenotypeVCF {
  Array[String] chromosomes

  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict

  Array[File] input_gvcfs
  Array[File] input_gvcfs_index

  scatter(chr in chromosomes) {
    call CombineGVCFsAndJointGenotypePerChr {
      input: chr=chr, 
             input_gvcfs=input_gvcfs,
             input_gvcfs_index=input_gvcfs_index,
             GATK=GATK,
             ref_fasta=ref_fasta,
             ref_fasta_index=ref_fasta_index,
             ref_dict=ref_dict
    }
  }

  call GatherVCFs {
    input: input_vcfs=CombineGVCFsAndJointGenotypePerChr.vcf,
           GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict
  }

} 


