## Family SNP Analysis 

### GATK Pipeline
We start with the Fastq files for 10 individuals in 3 families and use Gatk 4
to call variants. The Cromwell pipeline files for alignment, haplotype caller
and joint genotyping with VQSR steps are available [in the cromwell
directory](../cromwell/). The output of the pipeline steps gives us a VCF file
with raw variants. 

### QC steps
Started with the vcf file perform further QC steps. \[[qc\_vcf\_file.bash](../scripts/qc_vcf_file.bash)\]
1. **QC check**. Ts/Tv ratio is 2.861 in the exonic region 
1. **Select Variants** that pass filtering and are of good quality `minDP=5, minGQ=20, missing=0.1` 
1. **Convert to `hg19`** using Picard's Liftover tool and also sort it. \[[sort\_vcf\_files\_pre\_gen.bash](../scripts/sort_vcf_files_pre_gen.bash)\]

We are left with approximately 9.5M variants. 

### Annotating variants
We use Annovar to annotate using the following Bash script
\[[annotate\_variants.bash](../scripts/annotate_variants.bash)\]. We have the
following variants in each annotated region.

```
  Count Func.refGene
  ----- ------------
  66105 downstream 
  49445 exonic 
     66 exonic;splicing 
5214155 intergenic 
3379976 intronic 
  32143 ncRNA_exonic 
      8 ncRNA_exonic;splicing 
 584081 ncRNA_intronic 
    188 ncRNA_splicing 
      6 ncRNA_UTR5 
    405 splicing 
  61720 upstream 
   2239 upstream;downstream 
  72485 UTR3 
  15248 UTR5 
     43 UTR5;UTR3 
```

### Filtering steps
We filter these variants to look for causal variants in the exonic, splicing
and some regulatory regions. The python script to filter variants is at
\[[filter\_annovar\_output.py](../scripts/filter_annovar_output.py)\] and the
bash script that calls the python script is at
\[[filter\_annovar\_output.bash](../scripts/filter_annovar_output.bash)\]. 

1. Filter annotated variants by matching the *all* of following three main rules     
    1. `MAF` < 0.05 or unknown
    1. Not a `genomic_superdups` region
    1. `CADD` score > 12.37 or unknown
1. If the variant is in the Exonic region or splicing region match *any one* of
   the following three subrules to keep the variant 
    * `ExonicFunc` is not `synonymous SNV` and not `nonsynonymous SNV`
    * `ExonicFunc` is `nonsynonymous SNV`
    * `ExonicFunc` is `synonymous SNV` and Func.refGene is in `exonic;splicing`
1. If the variant is not in the exonic or splicing regions then we are probably
   in a regulatory region and so match *all* the following rules to keep the variant
    * `RegulomeDB_dbSNP141_Score` is not 6 or 7
    * `wgEncodeRegTfbsClusteredV3` or `tfbsConsSites` is not empty
    * `wgEncodeRegDnaseClusteredV3` is not empty
    * `gerp++ score` > 2

After filtering we are left with approximately 16k variants.

