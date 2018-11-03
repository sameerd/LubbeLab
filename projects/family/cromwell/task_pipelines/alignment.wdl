## Tasks to align WGS data from HiSeq FASTQ files
## Uses BWA/SAMTOOLS/GATK4

# This task takes an ID and two input fasta files that are gzipped. 
# It does all the BAM file processing and ends up with a small 
# .bam file ready for variant calling
task alignment_task {

  String ID
  File input_file_1_gz
  File input_file_2_gz

  String BWA
  String GATK4
  String GENOMEREF_V37
  String GENOMEREF_V37_INDEX
  String SAMTOOLS
  
  String PICARD_ARG_STR

  # We have a max of 24 cores on the genomics nodes
  # Also 128GB max of memory
  Int core_count = 12
  String gatk_mem_str = "30G"
  String samtools_mem_str = "5G" # this is memory per-thread

  # memory requested for this task should be greater than
  # max(gatk_men, samtools_mem * core_count) 
  # and if this larger than 100GB then we should reduce the samtools_mem
  # for now let's hard code sensible values
  String task_mem_str = "64gb"

  command {
      module load java

      # aligns reads in the FastQ to the reference genome to create a SAM file
      ${BWA} mem -M -t ${core_count} \
          -R $'@RG\tID:${ID}\tSM:${ID}\tLB:${ID}\tPL:ILLUMINA' \
          "${GENOMEREF_V37}" \
          <(zcat "${input_file_1_gz}") \
          <(zcat "${input_file_2_gz}") \
        > "${ID}.sam"

      # creates a BAM file from the SAM file
      ${SAMTOOLS} view -bS \
          -t "${GENOMEREF_V37_INDEX}" \
          -@${core_count} \
          -o "${ID}.bam" \
          "${ID}.sam" \

      # sort the BAM file
      ${SAMTOOLS} sort \
          -m ${samtools_mem_str} \
          -@${core_count} \
          "${ID}.bam" \
          -o "${ID}_sorted.bam" \
      
      # creates an index file for the BAM file
      ${SAMTOOLS} index "${ID}_sorted.bam"
    
      # Mark Duplicates
      ${GATK4} --java-options -Xmx${gatk_mem_str} MarkDuplicates \
        ${PICARD_ARG_STR} \
        --INPUT="${ID}_sorted.bam" \
        --OUTPUT="${ID}_sorted_unique.bam" \
        --METRICS_FILE="${ID}_picard_metrics.out"

      # creates an index file for the BAM file
      ${SAMTOOLS} index "${ID}_sorted_unique.bam"
  }
  output {
      File bam_file = "${ID}_sorted_unique.bam"
      File bam_file_index = "${bam_file}" + ".bai"
  }

  runtime {
    rt_alloc : "b1042"
    rt_queue : "genomics"
    rt_naccesspolicy : "singlenode"
    rt_walltime : "48:00:00"
    rt_nodes : 1
    rt_ppn : core_count
    rt_mem : task_mem_str
  }
}
