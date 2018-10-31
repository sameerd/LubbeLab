### Family 2
Started with the annotated vcf file provided 
`NM_SS400_EXOMEonly_02102017_EXOME_SNP.recal.snps.indel_VQSR_hardFiltered.vcf_alleleReduction.vcf.recode.vcf`
1. Convert this file to `hg19` using Picard's Liftover tool and also sort it. \[[Link to script](../scripts/sort_vcf_files_pre_gen.bash)\]
1. Extract family2 samples \[[Link to script](../scripts/extract_family2_samples_from_pre_gen.bash)\]
1. Annotate variants with annovar \[[Link to script](../scripts/annotate_variants.bash)\]
1. Filtered Annotated variants by keeping the following \[[Link to script](../scripts/filter_family2_annovar_output.bash)\]
    1. MAF < 0.05
    1. Exonic region or splicing region
    1. Filter ExonicFunc.refGene and Func.refGene by keeping
        * If ExonicFunc is not `synonymous SNV` and not `nonsynonymous SNV`
        * If ExonicFunc is `nonsynonymous SNV`
        * If ExonicFunc is `nsynonymous SNV` and Func.refGene is in `exonic:splicing`
1. Kept variants which matched the disease pattern \[[Link to script](../scripts/filter_family2_small_output.R)\]