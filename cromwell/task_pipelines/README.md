## Task Pipelines

This directory has all the tasks that we uses in the workflows 


### [Alignment.wdl](alignment.wdl)
This file does the alignment step together with some BAM file processing to end
up with a sorted unique BAM file ready for further processing. 

### [Haplotype\_Caller.wdl](haplotype_caller.wdl)
This file takes the sorted deduped BAM file and makes it a gvcf

### [Joint\_Genotype](joint_genotype.wdl)
These tasks combine gvcf files and do the filtering / VQSR steps

### [Parliament2](parliament2.wdl)
This file runs the [Parliament2](https://www.biorxiv.org/content/10.1101/424267v1) container. 

### [Utilities.wdl](utilities.wdl)
This file has utilities for resource definitions and other misc tasks. 

