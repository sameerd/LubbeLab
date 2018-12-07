## This pipeline workflow takes a list of sorted_unique.bam files and creates
## gvcf files out of them (Does not use SPARK)

import "./task_pipelines/haplotype_caller.wdl" as HaplotypeCaller

# WORKFLOW DEFINITION
workflow haplotype_caller_sub_workflow {

  String sample_name
  String input_bam_file
  String GATK4
  String ref_fasta
  String ref_fasta_index

  Array[String] chromosomes
  
  # FIXME: Add the ability to add multiple BAM files per sample
  scatter(chr in chromosomes) {
    call HaplotypeCaller.HaplotypeCallerERCPerChr {
      input: chr=chr, 
             input_bam_file=input_bam_file,
             input_bam_file_index=input_bam_file + ".bai",
             GATK4=GATK4,
             ref_fasta=ref_fasta,
             ref_fasta_index=ref_fasta_index
    }
  }
  call HaplotypeCaller.GatherGVCFs as hc_gather {
    input: sample_name=sample_name, 
           input_gvcfs=HaplotypeCallerERCPerChr.gvcf,
           GATK4=GATK4,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
  }

  output {
    File gvcf_file = hc_gather.gvcf_file
  }


}
