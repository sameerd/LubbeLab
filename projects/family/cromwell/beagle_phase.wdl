task BeaglePhasePerChr {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict

  String chr
  File input_vcf
  File input_vcf_index

  File Beagle
  File BeagleGeneticMapDir
  File BeagleBref3Dir

  command {
    java -jar -Xmx15G ${GATK} \
      -R ${ref_fasta} \
      -T SelectVariants \
      -V ${input_vcf} \
      -L ${chr} \
      -o chr.vcf.gz

    java -jar -Xmx60G ${Beagle} \
        gt=chr.vcf.gz \
        map="${BeagleGeneticMapDir}/plink.chr${chr}.GRCh37.map" \
        ref="${BeagleBref3Dir}/chr${chr}.1kg.phase3.v5a.b37.bref3" \
        out=beagle_out_${chr} \
        window=250.0 \
        chrom=${chr}

  }
  output {
    File vcf = "beagle_out_${chr}.vcf.gz"
    File log = "beagle_out_${chr}.log"
  } 
  runtime {
    rt_ppn: 8
    rt_mem: "64gb"
    rt_walltime: "5:00:00"
  }
}

task BeagleResultsGather {
  Array[File] input_vcfs
  Array[File] input_logs

  File output_directory

  command {
    cp \
      ${sep="  " input_vcfs} \
      ${sep="  " input_logs} \
      ${output_directory}
  }
  output {
  }
  runtime {
    rt_mem: "2gb"
    rt_walltime: "4:00:00"
  }
}


workflow BeaglePhase {
  Array[String] chromosomes

  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict

  File Beagle
  File BeagleGeneticMapDir
  File BeagleBref3Dir

  File input_vcf
  File input_vcf_index

  File output_directory

  scatter(chr in chromosomes) {
    call BeaglePhasePerChr {
      input: chr=chr, 
             input_vcf=input_vcf,
             input_vcf_index=input_vcf_index,
             GATK=GATK,
             ref_fasta=ref_fasta,
             ref_fasta_index=ref_fasta_index,
             ref_dict=ref_dict,
             Beagle=Beagle,
             BeagleGeneticMapDir=BeagleGeneticMapDir,
             BeagleBref3Dir=BeagleBref3Dir
    }
  }
  call BeagleResultsGather {
    input: input_vcfs=BeaglePhasePerChr.vcf,
           input_logs=BeaglePhasePerChr.log,
           output_directory=output_directory
  }

} 


