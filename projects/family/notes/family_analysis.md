## Family SNP Analysis 

#### GATK Pipeline
We start with the Fastq files for 10 individuals in 3 families and use Gatk 4
to call variants. The Cromwell pipeline files for alignment, haplotype caller
and joint genotyping with VQSR steps are available [in the cromwell
directory](../cromwell/). The output of the pipeline steps gives us a VCF file
with raw variants. 

#### QC steps
Started with the vcf file perform further QC steps. \[[qc\_vcf\_file.bash](../scripts/qc_vcf_file.bash)\]
1. **QC check**. Ts/Tv ratio is 2.861 in the exonic region 
1. **Select Variants** that pass filtering and are of good quality `minDP=5, minGQ=20, missing=0.1` 
1. **Convert to `hg19`** using Picard's Liftover tool and also sort it. \[[sort\_vcf\_files\_pre\_gen.bash](../scripts/sort_vcf_files_pre_gen.bash)\]

We are left with approximately 9.5M variants. 

#### Annotating variants
We use Annovar to annotate using the following Bash script
\[[annotate\_variants.bash](../scripts/annotate_variants.bash)\]. We have the
following variants in each annotated region.

| ---:   | :--- |
|  66105 | downstream |
|  49445 | exonic |
|     66 | exonic;splicing |
|5214155 | intergenic |
|3379976 | intronic |
|  32143 | ncRNA\_exonic |
|      8 | ncRNA\_exonic;splicing |
| 584081 | ncRNA\_intronic |
|    188 | ncRNA\_splicing |
|      6 | ncRNA\_UTR5 |
|    405 | splicing |
|  61720 | upstream |
|   2239 | upstream;downstream |
|  72485 | UTR3 |
|  15248 | UTR5 |
|     43 | UTR5;UTR3 |

#### Filtering steps
We filter these variants to look for causal variants in the exonic, splicing and some regulartory regions. \[[Filter python script](./scripts/filter_annovar_output.py)\]

1. **Filter** annotated variants by matching the *all* of following four main rules     
    1. MAF < 0.05
    1. Exonic region or splicing region
    1. Not a genomic\_superdups region
    1. Match *any one* of the following three subrules to match this rule
        * ExonicFunc is not `synonymous SNV` and not `nonsynonymous SNV`
        * ExonicFunc is `nonsynonymous SNV`
        * ExonicFunc is `synonymous SNV` and Func.refGene is in `exonic:splicing`


