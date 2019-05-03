
## Tasks to pick up the default resources
## These are just File/String pointers to programs and references
task fetch_resources {
  String progams_dir = "/projects/b1049/genetics_programs"
  String refs_dir = "/projects/b1049/genetics_refs"
 
  String? human_ref = "human_g1k_v37.fasta"
  # change to using hs37d5.fa in inputs.json

  # remove an extension that is .fa or .fasta or something like that
  String human_ref_basename = sub(basename(human_ref), "\\.fa[a-zA-Z0-9]+$", "")

  String project_tmp_dir = "/projects/b1042/LubbeLab/testtemp"
  String picard_tmp_dir = "--TMP_DIR=${project_tmp_dir}"

  # picard options style (below) is changing in a future release
  String picard_options = 
    "--ASSUME_SORTED=TRUE --REMOVE_DUPLICATES=FALSE --VALIDATION_STRINGENCY=LENIENT" 
  
  command {
    # We do nothing in this block but perhaps we could test for versions
    # later or test to see if programs exist
    echo " "
  }

  output {
    # Programs
    String GATK4 = "${progams_dir}/gatk_2018/gatk-4.0.10.0/gatk" 
    String VCFTOOLS = "${progams_dir}/vcftools/bin/vcftools"
    String BWA = "${progams_dir}/bwa-0.7.12/bwa"
    String SAMTOOLS = "${progams_dir}/samtools/samtools"
    String PARLIAMENT2 = "${progams_dir}/parliament2/parliament2_latest.sif"

    # ReferenceFiles
    # If the Ref's below are coded as `Files` instead of `Strings` then
    # they get localized into the execution directory. If we localize the
    # few files that are named below then we lose access to the .dict .bwi
    # .ann .pac etc files We would need to localize all of them by naming
    # them below.  A shortcut (bad!) is to name them as strings so that we
    # actually reference the original locations and the other files are
    # automatically picked up from there. 
    String GENOMEREF_V37 = "${refs_dir}/fasta/${human_ref}"
    String GENOMEREF_V37_INDEX = "${GENOMEREF_V37}.fai"
    String GENOMEREF_V37_DICT = "${refs_dir}/fasta/${human_ref_basename}.dict"

    String GENOMEREF_V37_2BIT = "${refs_dir}/fasta/human_g1k_v37.2bit"

    # Additional Arguments
    String PICARD_ARG_STR = "${picard_tmp_dir}" + " " + "${picard_options}"
  }

  runtime {
    rt_queue : "genomics"
    rt_walltime : "10:00"
  }
}

# Copy output to a final directory outside the cromwell structure
# From: https://github.com/broadinstitute/cromwell/issues/1641
task final_copy {
  Array[File] files
  String destination

  command {
    mkdir -p ${destination}
    cp -L -R -u ${sep=' ' files} ${destination}
  }

  output {
    Array[File] out = files
  }
  runtime {
    rt_queue : "genomics"
    rt_walltime : "4:00:00"
  }
}


# Strip the leading hash from file lines as we want to use this as a
# comment character
task strip_leading_hash {

  File input_file
  String output_file_name = "file_nohash"

  command {
    # Remove all lines that start with a hash
    grep -v "^#" "${input_file}" > "${output_file_name}"
  }

  output {
      File out = output_file_name
  }

  runtime {
    rt_queue : "genomics"
    rt_walltime : "10:00"

  }
}

## Task to gunzip files
task gunzip_file {

  File input_file
  String output_file_name = basename(input_file, ".gz")

  command {
    gunzip < "${input_file}" > "${output_file_name}"
  }
 
  output {
    File gunzipped_file = output_file_name
  }

  runtime {
    rt_queue : "genomics"
    rt_walltime : "03:59:00"
  }



}
