
## Tasks to pick up the default resources
## These are just File/String pointers to programs and references
task fetch_resources {
  String progams_dir = "/projects/b1049/genetics_programs"
  String refs_dir = "/projects/b1049/genetics_refs"

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
    String BWA = "${progams_dir}/bwa-0.7.12/bwa"
    String SAMTOOLS = "${progams_dir}/samtools/samtools"

    # ReferenceFiles
    # If the Ref's below are coded as `Files` instead of `Strings` then
    # they get localized into the execution directory. If we localize the
    # few files that are named below then we lose access to the .dict .bwi
    # .ann .pac etc files We would need to localize all of them by naming
    # them below.  A shortcut (bad!) is to name them as strings so that we
    # actually reference the original locations and the other files are
    # automatically picked up from there. 
    String GENOMEREF_V37 = "${refs_dir}/fasta/human_g1k_v37.fasta"
    String GENOMEREF_V37_INDEX = "${refs_dir}/fasta/human_g1k_v37.fastai"

    # Additional Arguments
    String PICARD_ARG_STR = "${picard_tmp_dir}" + " " + "${picard_options}"
  }

  runtime {
    rt_queue : "short"
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
    rt_queue : "short"
    rt_walltime : "4:00:00"
  }
}


# Strip the leading hash from file lines as we want to use this as a
# comment character
task strip_leading_hash {

  File input_file
  String output_file_name = "input_file_nohash"

  command {
    # Remove all lines that start with a hash
    grep -v "^#" "${input_file}" > input_file_nohash
  }

  output {
      File out = output_file_name
  }

  runtime {
    rt_queue : "short"
    rt_walltime : "10:00"

  }
}
