## This pipeline workflow takes in a tsv file of ID's and two gzipped FASTA
## files per ID and it outputs a BAM file that is ready for variant calling.


import "./task_pipelines/utilities.wdl" as Utilities
import "./task_pipelines/alignment.wdl" as Alignment


# WORKFLOW DEFINITION
workflow alignment_workflow {

  # This is a tsv file where the first column is the sample ID
  # The second column is the full path to the first fastq.gz file
  # The third column is the full path to the second fastz.gz file
  File input_samples_file
  String output_destination_dir

  Array[Array[String]] input_samples = read_tsv(input_samples_file)

  call Utilities.fetch_resources as Definitions {
  }
  
  scatter (sample in input_samples) {
    call Alignment.alignment_task {
      input:
        ID=sample[0],
        input_file_1_gz = sample[1],
        input_file_2_gz = sample[2],
        BWA = Definitions.BWA,
        GATK4 = Definitions.GATK4,
        GENOMEREF_V37 = Definitions.GENOMEREF_V37,
        GENOMEREF_V37_INDEX = Definitions.GENOMEREF_V37_INDEX,
        SAMTOOLS = Definitions.SAMTOOLS,
        PICARD_ARG_STR = Definitions.PICARD_ARG_STR
    }
  }

  Array[Array[File]] output_files = [alignment_task.bam_file, 
        alignment_task.bam_file_index]
  Array[File] output_files_flatten = flatten(output_files)

  call Utilities.final_copy {
    input:
      files = output_files_flatten,
      destination = output_destination_dir
  }

}
