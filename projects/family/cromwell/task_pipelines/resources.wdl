
## Tasks to pick up the default resources
## These are just FILE pointers to programs and references
task FetchResources {
  File progams_dir = "/projects/b1049/genetics_programs"
  File refs_dir = "/projects/b1049/genetics_refs"

  output {
    # Programs
    File GATK4 = "${progams_dir}/gatk_2018/gatk-4.0.10.0/gatk" 
    File BWA = "${progams_dir}/bwa-0.7.12/bwa"
    File SAMTOOLS = "${progams_dir}/samtools/samtools"

    # ReferenceFiles
    File GNOMEREF_V37 = "${refs_dir}/fasta/human_g1k_v37.fasta"
    File GNOMEREF_V37_INDEX = "${refs_dir}/fasta/human_g1k_v37.fastai"
  }



}
