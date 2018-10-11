task CombineGVCFsAndJointGenotypePerChr {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  String chr
  Array[File] input_gvcfs
  Array[File] input_gvcfs_index

  command {
    java -jar -Xmx15G ${GATK} \
      -T CombineGVCFs \
      -R ${ref_fasta} \
      -V ${sep=" -V " input_gvcfs} \
      -L ${chr} \
      -o combined.g.vcf.gz

    java -jar -Xmx15G ${GATK} \
      -T GenotypeGVCFs \
      -R ${ref_fasta} \
      -V combined.g.vcf.gz \
      -L ${chr} \
      --includeNonVariantSites \
      -o combined.vcf.gz
  }
  output {
    File vcf = "combined.vcf.gz"
  } 
  runtime {
    rt_mem: "16gb"
    rt_walltime: "40:00:00"
  }
}


task GatherVCFs {
  Array[File] input_vcfs
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  
  command {
    java -cp ${GATK} org.broadinstitute.gatk.tools.CatVariants \
    -R ${ref_fasta} \
    -V ${sep=" -V " input_vcfs} \
    -out out.vcf.gz
  }
  output {
    File vcf = "out.vcf.gz"
    File vcf_index = vcf + ".tbi"
  }
  runtime {
    rt_mem: "16gb"
    rt_walltime: "40:00:00"
  }
}

task GatherVCFsProxy {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict
  
  command {
    echo java -jar -Xmx15G ${GATK} \
      -T SelectVariants \
      -R ${ref_fasta} \
      -V /projects/b1049/sameer/LubbeLab/projects/family/data/input/tmp/out.vcf.gz \
      -o out.vcf.gz
  }
  output {
    File vcf= "/projects/b1049/sameer/LubbeLab/projects/family/data/input/tmp/out.vcf.gz"
    File vcf_index = vcf + ".tbi"
  }
  runtime {
    rt_mem: "1gb"
    rt_walltime: "10:00"
  }
}


task HardFilterAndFlagPerChr {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict

  String chr

  File input_vcf
  File input_vcf_index

  command {
    java -jar -Xmx15G ${GATK} \
      -T VariantFiltration \
      -R ${ref_fasta} \
      -V ${input_vcf} \
      -L ${chr} \
      --genotypeFilterExpression "DP < 5" \
      --genotypeFilterName "LowDepth" \
      --genotypeFilterExpression "GQ < 20.0 && GQ > 0.0" \
      --genotypeFilterName "LowGQ" \
      -o out_filter.vcf.gz 

    java -jar -Xmx15G ${GATK} \
      -R ${ref_fasta} \
      -T SelectVariants \
      -V out_filter.vcf.gz \
      -o out.vcf.gz

  }
  output {
    File vcf = "out.vcf.gz"
    File vcf_index = vcf + ".tbi"
  } 
  runtime {
    rt_mem: "16gb"
    rt_walltime: "40:00:00"
  }
}


task VariantRecalibratorSNP {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict


  File input_vcf
  File input_vcf_index

  String VQSRargsSNP=" -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an InbreedingCoeff --maxGaussians 5"
  String VQSRresourcesSNP=" -resource:hapmap,known=false,training=true,truth=true,prior=15.0 /projects/b1049/genetics_refs/hapmap_3.3.hg19.sites.vcf -resource:omni,known=false,training=true,truth=true,prior=12.0 /projects/b1049/genetics_refs/1000G_omni2.5.hg19.sites.vcf -resource:1000G,known=false,training=true,truth=false,prior=10.0 /projects/b1049/genetics_refs/1000G_phase1.snps.high_confidence.hg19.sites.vcf -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 /projects/b1049/genetics_refs/dbsnp_138.hg19.vcf"

 command {
    java -jar -Xmx15G ${GATK} \
      -R ${ref_fasta} \
      -T VariantRecalibrator \
      -input ${input_vcf} \
      -mode SNP \
      -recalFile SNP_recal \
      -tranchesFile SNP_tranches \
      -rscriptFile plots.R \
      ${VQSRargsSNP} \
      ${VQSRresourcesSNP}
  }
  output {
    File recal = "SNP_recal"
    File tranches = "SNP_tranches"
  } 
  runtime {
    rt_mem: "16gb"
    rt_walltime: "40:00:00"
  }
}

task VariantRecalibratorINDEL {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict


  File input_vcf
  File input_vcf_index

  String VQSRargsINDEL=" -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --maxGaussians 4 -an QD -an DP -an FS -an SOR -an ReadPosRankSum -an MQRankSum -an InbreedingCoeff"
  String VQSRresourcesINDEL="-resource:mills,known=false,training=true,truth=true,prior=12.0 /projects/b1049/genetics_refs/Mills_and_1000G_gold_standard.indels.hg19_modified.vcf -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 /projects/b1049/genetics_refs/dbsnp_138.hg19.vcf"

 command {
    java -jar -Xmx15G ${GATK} \
      -R ${ref_fasta} \
      -T VariantRecalibrator \
      -input ${input_vcf} \
      -mode INDEL \
      -recalFile INDEL_recal \
      -tranchesFile INDEL_tranches \
      -rscriptFile plots.R \
      ${VQSRargsINDEL} \
      ${VQSRresourcesINDEL}
  }
  output {
    File recal = "INDEL_recal"
    File tranches = "INDEL_tranches"
  } 
  runtime {
    rt_mem: "16gb"
    rt_walltime: "40:00:00"
  }
}



task ApplyRecalibrationSNPINDEL {
  File GATK

  File ref_fasta 
  File ref_fasta_index
  File ref_dict

  File input_vcf
  File input_vcf_index

  File SNP_recal
  File SNP_tranches

  File INDEL_recal
  File INDEL_tranches

  String VQSRFILTERLEVEL= "99.9"

 command {

    java -jar -Xmx15G ${GATK} \
      -R ${ref_fasta} \
      -T ApplyRecalibration \
      -mode SNP \
      --ts_filter_level ${VQSRFILTERLEVEL} \
      -input ${input_vcf} \
      -recalFile ${SNP_recal} \
      -tranchesFile ${SNP_tranches} \
      -o SNP.recal.snps.vcf.gz

    java -jar -Xmx15G ${GATK} \
      -R ${ref_fasta} \
      -T ApplyRecalibration \
      -mode INDEL \
      --ts_filter_level ${VQSRFILTERLEVEL} \
      -input SNP.recal.snps.vcf.gz \
      -recalFile ${INDEL_recal} \
      -tranchesFile ${INDEL_tranches} \
      -o out.vcf.gz
  }
  output {
    File vcf = "out.vcf.gz"
    File vcf_index = vcf + ".tbi"
  } 
  runtime {
    rt_mem: "16gb"
    rt_walltime: "40:00:00"
  }
}

task FlagVariants {
  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict

  File VCFTOOLS 

  File input_vcf
  File input_vcf_index

 command {

    ${VCFTOOLS} \
      --gzvcf ${input_vcf} \
      --max-alleles 8 \
      --recode \
      --recode-INFO-all \
      --stdout | gzip -c > allele_reduction.vcf.gz

    java -jar -Xmx15G ${GATK} \
      -R ${ref_fasta} \
      -T SelectVariants \
      -V allele_reduction.vcf.gz \
      -o out.vcf.gz

  }
  output {
    File vcf = "out.vcf.gz"
    File vcf_index = vcf + ".tbi"
  } 
  runtime {
    rt_mem: "16gb"
    rt_walltime: "40:00:00"
  }
}


workflow CreateJointGenotypeVCF {
  Array[String] chromosomes

  File GATK
  File ref_fasta 
  File ref_fasta_index
  File ref_dict

  File VCFTOOLS

  Array[File] input_gvcfs
  Array[File] input_gvcfs_index

  #scatter(chr in chromosomes) {
  #  call CombineGVCFsAndJointGenotypePerChr {
  #    input: chr=chr, 
  #           input_gvcfs=input_gvcfs,
  #           input_gvcfs_index=input_gvcfs_index,
  #           GATK=GATK,
  #           ref_fasta=ref_fasta,
  #           ref_fasta_index=ref_fasta_index,
  #           ref_dict=ref_dict
  #  }
  #}

  #call GatherVCFs {
  #  input: input_vcfs=CombineGVCFsAndJointGenotypePerChr.vcf,
  #         GATK=GATK,
  #         ref_fasta=ref_fasta,
  #         ref_fasta_index=ref_fasta_index,
  #         ref_dict=ref_dict
  #}

  ## Lets break the workflow for now and start here for debugging purposes
  ##  FIXME: remove GatherVCFsProxy later
  call GatherVCFsProxy {
    input: GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict
  }

  scatter(chr in chromosomes) {
    call HardFilterAndFlagPerChr {
      input: GATK=GATK,
             ref_fasta=ref_fasta,
             ref_fasta_index=ref_fasta_index,
             ref_dict=ref_dict,
             input_vcf=GatherVCFsProxy.vcf,
             input_vcf_index=GatherVCFsProxy.vcf_index,
             chr=chr
    }
  }
  call GatherVCFs as HardFilterAndFlag {
    input: input_vcfs=HardFilterAndFlagPerChr.vcf,
           GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict
  }

    
  call VariantRecalibratorSNP {
    input: GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict,
           input_vcf=HardFilterAndFlag.vcf,
           input_vcf_index=HardFilterAndFlag.vcf_index
  }
  call VariantRecalibratorINDEL {
    input: GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict,
           input_vcf=HardFilterAndFlag.vcf,
           input_vcf_index=HardFilterAndFlag.vcf_index
  }

  call ApplyRecalibrationSNPINDEL {
    input: GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict,
           SNP_recal=VariantRecalibratorSNP.recal,
           SNP_tranches=VariantRecalibratorSNP.tranches,
           INDEL_recal=VariantRecalibratorINDEL.recal,
           INDEL_tranches=VariantRecalibratorINDEL.tranches,
           input_vcf=HardFilterAndFlag.vcf,
           input_vcf_index=HardFilterAndFlag.vcf_index
  }

  call FlagVariants {
    input: GATK=GATK,
           ref_fasta=ref_fasta,
           ref_fasta_index=ref_fasta_index,
           ref_dict=ref_dict,
           VCFTOOLS=VCFTOOLS,
           input_vcf=ApplyRecalibrationSNPINDEL.vcf,
           input_vcf_index=ApplyRecalibrationSNPINDEL.vcf_index
  }



} 


