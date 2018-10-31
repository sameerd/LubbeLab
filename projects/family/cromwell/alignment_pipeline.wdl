## This pipeline workflow takes in a tsv file of ID's and two gzipped FASTA
## files per ID and it outputs a BAM file that is ready for variant calling.


import "./task_pipelines/resources.wdl" as Resources
import "./task_pipelines/alignment.wdl" as Alignment


# WORKFLOW DEFINITION
workflow alignment_workflow {
  String ID="SS4009023"

  File gz1 = "/projects/b1049/Niccolo_NGS/genomes/SS4009023/SS4009023_ST-E00180_234_L1_1.fq.gz"
  File gz2 = "/projects/b1049/Niccolo_NGS/genomes/SS4009023/SS4009023_ST-E00180_234_L1_2.fq.gz"

  call Resources.fetch_resources as Definitions {

  }

  call Alignment.alignment_task {
    input:
      ID=ID,
      input_file_1_gz = gz1,
      input_file_2_gz = gz2,
      BWA = Definitions.BWA,
      GATK4 = Definitions.GATK4,
      GENOMEREF_V37 = Definitions.GENOMEREF_V37,
      GENOMEREF_V37_INDEX = Definitions.GENOMEREF_V37_INDEX,
      SAMTOOLS = Definitions.SAMTOOLS,
      PICARD_ARG_STR = Definitions.PICARD_ARG_STR
  }


}
