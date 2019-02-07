## This pipeline workflow takes in a tsv file of BAM files
## it outputs a set of VCF files (one per BAM file) that is 
## the output of the parliament2 container


import "./task_pipelines/utilities.wdl" as Utilities
import "./task_pipelines/parliament2.wdl" as Parliament2


# WORKFLOW DEFINITION
workflow parliament_workflow {

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

  Array[Array[String]] input_samples = 
        read_tsv(strip_leading_hash.out)

  call Utilities.fetch_resources as Definitions {
  }

  # First create all the vcf files for SV
  scatter (sample in input_samples) {
    String input_file_bam = real_input_file_prefix + sample[0]

    call Parliament2.parliament2 {
      input:
        input_file_bam = input_file_bam,
        input_file_bam_index = input_file_bam + ".bai",
        PARLIAMENT2 = Definitions.PARLIAMENT2,
        GENOMEREF_V37 = Definitions.GENOMEREF_V37,
        GENOMEREF_V37_INDEX = Definitions.GENOMEREF_V37_INDEX
    }
  }

  # copy output files to output directory
  call Utilities.final_copy {
    input:
      files = parliament2.output_vcf,
      destination = output_destination_dir
  }

}
