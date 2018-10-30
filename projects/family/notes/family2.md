1. Started with the annotated vcf file provided to us
`NM_SS400_EXOMEonly_02102017_EXOME_SNP.recal.snps.indel_VQSR_hardFiltered.vcf_alleleReduction.vcf.recode.vcf`
    * Convert this file to `hg19` using Picard's Liftover tool and also sort it [script](../scripts/sort_vcf_files_pre_gen.bash)
    * Extract family2 samples [script](../scripts/extract_family2_samples_from_pre_gen.bash)
    * Annotate variants with annovar [script](../scripts/annotate_variants.bash)
    * Filtered Annotated variants by keeping the following
        1. MAF < 0.05
        2. Exonic region or splicing region
        3. Filter ExonicFunc.refGene and Func.refGene by keeping
            * If ExonicFunc is not `synonymous SNV` and not `nonsynonymous SNV`
            * If ExonicFunc is `nonsynonymous SNV`
            * If ExonicFunc is `nsynonymous SNV` and Func.refGene is in `exonic:splicing`
    * Kept variants which matched the disease pattern
