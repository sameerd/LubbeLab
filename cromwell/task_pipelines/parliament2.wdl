
# This task takes a BAM file and runs parliament2 on it. 
task parliament2 {

  String input_file_bam
  String input_file_bam_index

  String PARLIAMENT2
  String GENOMEREF_V37
  String GENOMEREF_V37_INDEX

  Int core_count = 24
  String task_mem_str = "120000"

  # basenames for singularity
  # We just need to strip out the directory here
  # These strings are used as input into the container
  String input_file_bam_basename = basename(input_file_bam)
  String input_file_bam_index_basename = basename(input_file_bam_index)
  String ref_basename = basename(GENOMEREF_V37)
  String ref_index_basename = basename(GENOMEREF_V37_INDEX)

  # here we also need to strip out the extension to figure out
  # what the output file will be named
  String ID = basename(input_file_bam_index_basename, ".bam")

  command {
      mkdir input output
      
      # copy files into input directory which singularity shall mount into 
      # the container. WARNING: singularity *will* modify these files
      cp "${GENOMEREF_V37}" \
         "${GENOMEREF_V37_INDEX}" \
         "${input_file_bam}" \
         "${input_file_bam_index}" input/


      TMPDIR=/tmp LANG= singularity run \
        -B `pwd`/input:/home/dnanexus/in:rw \
        -B `pwd`/output:/home/dnanexus/out:rw \
        ${PARLIAMENT2} \
          --bam "${input_file_bam_basename}" \
          --bai "${input_file_bam_index_basename}" \
          -r "${ref_basename}" \
          --fai "${ref_index_basename}" \
          --breakdancer --delly_deletion \
          --breakseq  --manta \
          --cnvnator --lumpy --genotype 
  }

  output { 
    # use output_vcf only if we really need to. Otherwise it is hard to 
    # guess what the combined output files will be called. It is 
    # commented out for now
    #File output_vcf = "output/${ID}.combined.genotyped.vcf"
    Array[File] vcfs = glob("output/*.vcf")
    Array[File] sv_caller_results = glob("output/sv_caller_results/*")
    Array[File] svtyped_vcfs = glob("output/svtyped_vcfs/*.vcf")
  }

  runtime {
    rt_alloc : "b1042"
    rt_queue : "genomics"
    rt_naccesspolicy : "--exclusive"
    rt_walltime : "48:00:00"
    rt_nodes : 1
    rt_ppn : core_count
    rt_mem : task_mem_str
  }

}


