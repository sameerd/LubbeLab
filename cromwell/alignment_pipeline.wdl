## This pipeline workflow takes in a tsv file of ID's and two gzipped FASTA
## files per ID and it outputs a BAM file that is ready for variant calling.


import "./task_pipelines/utilities.wdl" as Utilities
import "./task_pipelines/alignment.wdl" as Alignment


# WORKFLOW DEFINITION
workflow alignment_workflow {

  # This is a tsv file where the first column is the sample ID
  # The second column is the path to the first fastq.gz file
  # The third column is the path to the second fastz.gz file
  File input_samples_file

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
    input: input_file = input_samples_file
  }

  Array[Array[String]] input_samples = 
        read_tsv(strip_leading_hash.out)

  call Utilities.fetch_resources as Definitions {
  }

  # First create all the SAM files
  scatter (sample in input_samples) {
    String sample_id = sample[0]
    String input_file_1 = real_input_file_prefix + sample[1]
    String input_file_2 = real_input_file_prefix + sample[2]

    call Alignment.alignment_create_samfile {
      input:
        ID=sample_id,
        input_file_1_gz = input_file_1,
        input_file_2_gz = input_file_2,
        BWA = Definitions.BWA,
        GENOMEREF_V37 = Definitions.GENOMEREF_V37,
        GENOMEREF_V37_INDEX = Definitions.GENOMEREF_V37_INDEX
    }
  }

  # now process the SAM files into BAM files
  scatter (sam_file in alignment_create_samfile.sam_file) {
    call Alignment.alignment_task {
      input:
        sam_file=sam_file,
        GATK4 = Definitions.GATK4,
        GENOMEREF_V37 = Definitions.GENOMEREF_V37,
        GENOMEREF_V37_INDEX = Definitions.GENOMEREF_V37_INDEX,
        SAMTOOLS = Definitions.SAMTOOLS,
        PICARD_ARG_STR = Definitions.PICARD_ARG_STR
    }
  }

  # Merge all the bam files and index files into one array
  Array[Array[File]] output_files = [alignment_task.bam_file, 
        alignment_task.bam_file_index]
  Array[File] output_files_flatten = flatten(output_files)

  # copy output files to output directory
  call Utilities.final_copy {
    input:
      files = output_files_flatten,
      destination = output_destination_dir
  }

}
