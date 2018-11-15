### Family 2
Started with the annotated vcf file provided 
`NM_SS400_EXOMEonly_02102017_EXOME_SNP.recal.snps.indel_VQSR_hardFiltered.vcf_alleleReduction.vcf.recode.vcf`
1. **QC check**. Look at Ts/Tv ratio on exonic region only. \[[qc_on_exonic_only.bash](../scripts/qc_on_exonic_only.bash)\]
1. **Select Variants** that pass filtering and are of good quality \[[qc_pre_gen_vcf_file.bash](../scripts/qc_pre_gen_vcf_file.bash)\]
1. **Convert to `hg19`** using Picard's Liftover tool and also sort it. \[[sort_vcf_files_pre_gen.bash](../scripts/sort_vcf_files_pre_gen.bash)\]
1. **Select Samples** Extract family2 samples \[[Extract script](../scripts/extract_family2_samples_from_pre_gen.bash)\]
1. **Annotate** variants with annovar \[[annotate_variants.bash](../scripts/annotate_variants.bash)\]
1. **Filter** annotated variants by matching the *all* of following three rules \[[Filter script](../scripts/filter_family2_annovar_output.bash)\]
    1. MAF < 0.05
    1. Exonic region or splicing region
    1. Filter ExonicFunc.refGene and Func.refGene by matching *any one* of the following three subrules
        * ExonicFunc is not `synonymous SNV` and not `nonsynonymous SNV`
        * ExonicFunc is `nonsynonymous SNV`
        * ExonicFunc is `synonymous SNV` and Func.refGene is in `exonic:splicing`
1. Kept variants which matched the disease inheritance pattern \[[Filter script](../scripts/filter_family2_small_output.R)\]

