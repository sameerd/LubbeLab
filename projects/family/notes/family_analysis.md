### Family 2
Started with the annotated vcf file provided 
`NM_SS400_EXOMEonly_02102017_EXOME_SNP.recal.snps.indel_VQSR_hardFiltered.vcf_alleleReduction.vcf.recode.vcf`
1. **QC check**. Look at Ts/Tv ratio on exonic region only \[ [Link to script](../scripts/qc_on_exonic_only.bash)
1. **Select Variants**. Select variants that pass filtering and are of good quality \[[Link to script](../scripts/qc_pre_gen_vcf_file.bash)\]
1. **Convert to hg19** Convert this file to `hg19` using Picard's Liftover tool and also sort it. \[[Link to script](../scripts/sort_vcf_files_pre_gen.bash)\]
1. **Select Samples** Extract family2 samples \[[Link to script](../scripts/extract_family2_samples_from_pre_gen.bash)\]
1. **Annotate** Annotate variants with annovar \[[Link to script](../scripts/annotate_variants.bash)\]
1. **Filter** Filtered Annotated variants by matching the all of following three rules \[[Link to script](../scripts/filter_family2_annovar_output.bash)\]
    1. MAF < 0.05
    1. Exonic region or splicing region
    1. Filter ExonicFunc.refGene and Func.refGene by matching any one of the following three subrules
        * If ExonicFunc is not `synonymous SNV` and not `nonsynonymous SNV`
        * If ExonicFunc is `nonsynonymous SNV`
        * If ExonicFunc is `synonymous SNV` and Func.refGene is in `exonic:splicing`
1. Kept variants which matched the disease inheritance pattern \[[Link to script](../scripts/filter_family2_small_output.R)\]

