## Tasks to create GVCF files out of sorted BAM files

## This tasks takes a sorted (de-duped) BAM file and creates a 
## GVCF file # Uses GATK4 Spark
task haplotype_caller_task {


  # FIXME: Add the ability to add multiple bam files
  File input_bam_file

  Int? num_nodes = 2
  String? walltime = "24:00:00"

  String GATK4
  String GENOMEREF_V37_2BIT 

  String output_file_name = basename(input_bam_file, "*.bam") + ".g.vcf"
  
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
      -- --driver-cores=${num_nodes} \
         --driver-memory=12g \
         --executor-cores=22 \
         --executor-memory=108GB
  }
  output {
    File gvcf_file = "${output_file_name}"
  }
  runtime {
    rt_alloc : "b1042"
    rt_queue : "genomics"
    rt_walltime : walltime
    rt_nodes : num_nodes
    rt_ppn : 24
    rt_mem : "120gb"
    
  }

}

## This tasks takes a sorted (de-duped) BAM file and creates a 
## GVCF file per chromosome # Uses GATK4 
task HaplotypeCallerERCPerChr {

  String GATK4
  File ref_fasta 
  String chr
  File input_bam_file

  command {

    ${GATK4} --java-options "-Xmx7G" HaplotypeCaller \
      -R ${ref_fasta} \
      -I ${input_bam_file} \
      -L ${chr} \
      --emit-ref-confidence GVCF \
      -o raw.likelihood.g.vcf.gz
  }
  output {
    File gvcf = "raw.likelihood.g.vcf.gz"
  } 
  runtime {
    rt_mem: "8gb"
    rt_walltime: "24:00:00"
  }
}

task GatherGVCFs {
  Array[File] input_gvcfs
  String sample_name
  String GATK4
  File ref_fasta 
  
  command {
    ${GATK4} --java-options "-Xmx14G" GatherGVCFs \
    -R ${ref_fasta} \
    -V ${sep=" -V " input_gvcfs} \
    -O "${sample_name}.g.vcf.gz"
  }
  output {
    File gvcf_file = "${sample_name}.g.vcf.gz"
  }
  runtime {
    rt_mem: "16gb"
    rt_walltime: "9:00:00"
  }
}
