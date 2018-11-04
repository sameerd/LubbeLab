## Tasks to create GVCF files out of sorted BAM files
## Uses GATK4 Spark

## This tasks takes a sorted (de-duped) BAM file and creates a 
## GVCF file
task haplotype_caller_task {

  File input_bam_file

  String GATK4
  String GENOMEREF_V37_2BIT 

  String output_file_name = basename(input_bam_file, "*.bam") + "g.vcf.gz"
  
  command {
    ## Modified from https://kb.northwestern.edu/page.php?id=86687

    # Load environment
    module load spark/2.3.0

    # Initialize spark cluster inside job
    $SPARK_TOOLS/initialize_spark.sh

    # Run GATK HaplotypeCaller (core and memory settings are per-node)
    ${GATK4} HaplotypeCallerSpark \
      --reference "${GENOMEREF_V37_2BIT}" \
      --input "${input_bam_file}" \
      --emit-ref-confidence GVCF \
      --output ${output_file_name} \
      --spark-runner SPARK \
      --spark-master spark://`hostname -i`:7077 \
      -- --driver-cores=2 \
         --driver-memory=12g \
         --executor-cores=22 \
         --executor-memory=110GB
  }
  output {
    File gvcf_file = "${output_file_name}"
  }
  runtime {
    rt_alloc : "b1042"
    rt_queue : "genomics"
    rt_walltime : "03:00:00"
    rt_nodes : 2
    rt_ppn : 24
    
  }

}

