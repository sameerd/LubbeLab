
## Tasks to pick up the default resources
## These are just FILE pointers to programs and references
task fetch_resources {
  String progams_dir = "/projects/b1049/genetics_programs"
  String refs_dir = "/projects/b1049/genetics_refs"

  String project_tmp_dir = "/projects/b1042/LubbeLab/testtemp"

  String picard_tmp_dir = "TMP_DIR=${project_tmp_dir}"
  String picard_options = "ASSUME_SORTED=TRUE REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=LENIENT" 
  
  command {}

  output {
    # Programs
    String GATK4 = "${progams_dir}/gatk_2018/gatk-4.0.10.0/gatk" 
    String BWA = "${progams_dir}/bwa-0.7.12/bwa"
    String SAMTOOLS = "${progams_dir}/samtools/samtools"

    # ReferenceFiles
    File GENOMEREF_V37 = "${refs_dir}/fasta/human_g1k_v37.fasta"
    File GENOMEREF_V37_INDEX = "${refs_dir}/fasta/human_g1k_v37.fastai"

    # Additional Arguments
    String PICARD_ARG_STR = "${picard_tmp_dir}" + " " + "${picard_options}"
    
  }



}
