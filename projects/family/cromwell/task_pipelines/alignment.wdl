## Tasks to align WGS data from HiSeq FASTQ files
## All the BAM file processing tasks are in this file
## Uses BWA/SAMTOOLS/GATK4

# This workflow takes an ID and two files
# Then it does all the BAM file processing
# and ends up with small .bam files ready for variant calling


task alignment_task {

  String ID
  File input_file_1
  File input_file_2

  File BWA
  File GNOMEREF_V37
  File GNOMEREF_V37_INDEX
  File SAMTOOLS

  String picard_arguments = "TMP_DIR=/projects/b1042/LubbeLab/testtemp ASSUME_SORTED=TRUE REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=LENIENT" 

  Int core_count = 1
  String samtools_mem = "14G"
                       
  command {
      module load java

      # aligns reads in the FastQ to the reference genome to create a SAM file
      ${BWA} mem -M -t ${core_count} \
          -R "\$'@RG\tID:${ID}\tSM:${ID}\tLB:${ID}\tPL:ILLUMINA'" \ 
          ${GENOMEREF_V37} \
          "\$(zcat ${input_file_1}" \ 
          "\$(zcat ${input_file_2}" \  
        > "${ID}.sam"

      # creates a BAM file
      ${SAMTOOLS} view -bS \
          -t "${GENOMEREF_V37_INDEX}" \
          -@"${core_count}" \
          -o "${ID}.bam" \
          "${ID}.sam" \

      # sort the BAM file
      ${SAMTOOLS} sort \
          -m "${samtools_mem}" \
          -@"${core_count}" \
          "${ID}.bam" \
          -o "${ID}_sorted.bam" \
      
      # creates an index file for the BAM file
      ${SAMTOOLS} index "${ID}_sorted.bam" 
    
      # Mark Duplicates
      "${GATK4}" --java-options -Xmx10G MarkDuplicates \
        "${picard_arguments} \
        I="${ID}_sorted.bam" \
        O="${ID}_sorted_unique.bam" \
        METRICS_FILE="${ID}_picard_metrics.out" 

      # creates an index file for the BAM file
      ${SAMTOOLS} index "${ID}_sorted_unique.bam" 
  }
  output {
      File bam_file = "${ID}_sorted_unique.bam" 
      File bam_file_index = "${bam_file}" + ".bai"
  }

  runtime {
    rt_alloc = "b1042"
    rt_queue = "genomics"
    #PBS -l naccesspolicy=singlenode # Should we put in an option for this?
    rt_walltime= "48:00:00"
    rt_nodes = 1
    rt_ppn = 1
    rt_mem = "16gb"
  }
}
