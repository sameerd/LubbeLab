## This pipeline workflow takes a list of sorted_unique.bam files and creates
## gvcf files out of them # Uses SPARK

import "./task_pipelines/utilities.wdl" as Utilities
import "./task_pipelines/haplotype_caller.wdl" as HaplotypeCaller

# WORKFLOW DEFINITION
workflow haplotype_caller_workflow {

  # This is a text file with a list of bam files in it
  File input_bam_list_file

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
    input: input_file = input_bam_list_file
  }

  Array[Array[String]] input_bams = 
        read_tsv(strip_leading_hash.out)

  call Utilities.fetch_resources as Definitions {
  }

  scatter (sample in input_bams) {
    String input_bam_file = real_input_file_prefix + sample[0]

    # FIXME: Add the ability to add multiple BAM files per sample
    call HaplotypeCaller.haplotype_caller_task {
      input:
        input_bam_file = input_bam_file,
        GATK4 = Definitions.GATK4,
        GENOMEREF_V37_2BIT = Definitions.GENOMEREF_V37
    }
  }

  # copy output files to output directory
  call Utilities.final_copy {
    input:
      files = haplotype_caller_task.gvcf_file,
      destination = output_destination_dir
  }

}
