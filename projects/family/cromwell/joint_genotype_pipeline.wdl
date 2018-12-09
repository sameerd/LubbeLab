## This pipeline workflow takes a list of g.vcf.gz files and creates
## joint genotypes them (Does not use SPARK)

import "./task_pipelines/utilities.wdl" as Utilities
import "./task_pipelines/joint_genotype.wdl" as Genotyper

# WORKFLOW DEFINITION
workflow joint_genotype_workflow {

  # This is a text file with a list of bam files in it
  File input_gvcf_list_file

  # To use relative paths in the file above we should set the 
  # input_file_prefix variable so that when combined with 
  # fastq.gz files we get a full path
  String? input_file_prefix  # /projects/b1049/etc/etc
  # add a trailing / if we have an input_file_prefix
  String real_input_file_prefix = if defined(input_file_prefix) then input_file_prefix + "/" else ""  

  # Directory where we want the sorted_unique.bam and sorted_unique.bam.bai
  # files copied
  String output_destination_dir

  # Remove all the samples that are commented out with 
  # a leading hash (^#)
  call Utilities.strip_leading_hash {
    input: input_file = input_gvcf_list_file
  }

  Array[Array[String]] input_gvcfs = 
        read_tsv(strip_leading_hash.out)

  call Utilities.fetch_resources as Definitions {
  }

  # since this is an array of one dimensional arrays
  # we can just flatten it
  Array[String] input_gvcfs_with_path = prefix(real_input_file_prefix, 
                                               flatten(input_gvcfs))

  # Lets gunzip the vcf files
  scatter (vcf_gz in input_gvcfs_with_path) {
    call Utilities.gunzip_file as gunzipped_vcfs { 
      input: input_file = vcf_gz
    }
  }

  call Genotyper.CombineGVCFs {
    input:
      input_gvcfs = gunzipped_vcfs.gunzipped_file,
      GATK4=Definitions.GATK4,
      ref_fasta=Definitions.GENOMEREF_V37
  }
  
  call Genotyper.JointGenotype {
    input:
      combined_gvcf_file = CombineGVCFs.combined_gvcf_file,
      GATK4=Definitions.GATK4,
      ref_fasta=Definitions.GENOMEREF_V37
  }

  call Genotyper.ExtractandFilterSNPs {
    input:
      genotyped_raw_vcf_file = JointGenotype.genotyped_raw_vcf_file,
      GATK4=Definitions.GATK4,
      ref_fasta=Definitions.GENOMEREF_V37
  }

  call Genotyper.ExtractandFilterINDELs {
    input:
      genotyped_raw_vcf_file = JointGenotype.genotyped_raw_vcf_file,
      GATK4=Definitions.GATK4,
      ref_fasta=Definitions.GENOMEREF_V37
  }

  call Genotyper.CombineFilteredSNPsIndels {
    input:
      filtered_snps_vcf = ExtractandFilterSNPs.filtered_snps_vcf,
      filtered_indels_vcf = ExtractandFilterINDELs.filtered_indels_vcf,
      GATK4=Definitions.GATK4,
      ref_fasta=Definitions.GENOMEREF_V37
  }


  # copy output files to output directory
  #call Utilities.final_copy {
  #  input:
  #    files = sub_hc.gvcf_file,
  #    destination = output_destination_dir
  #}

}
