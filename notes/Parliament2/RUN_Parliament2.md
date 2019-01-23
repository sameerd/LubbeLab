### Running Parliament2 on quest

[Parliament 2](https://github.com/dnanexus/parliament2) is a docker container
that runs programs to generate Structural Variant calls with the following
callers: Breakdancer, Breakseq2, CNVnator, Delly2, Manta, and Lumpy. 

This code needs a few modifications before it can be run via Singularity.

* Code modifications [https://github.com/sameerd/parliament2](https://github.com/sameerd/parliament2)
* Singularity Container [https://www.singularity-hub.org/collections/2124](https://www.singularity-hub.org/collections/2124)

#### Preparing a dataset to run

1. Prepare a directory structure like the one below

---
**WARNING** Almost everything in this directory and its sub directories will
end up being modified in some way so it is best to copy files over 
---

```
.
├── parliament2_latest.sif
├── input/
│   ├── sample.bam
│   ├── sample.bai
│   ├── human_g1k_v37.fasta
│   └── human_g1k_v37.fasta.fai
└── output/
```

```shell
## commands to create a structure like the one above
# create a directory called work and sub directories
mkdir -p work/inputs work/outputs

# copy over reference files and zip them
cp /projects/b1049/genetics_refs/fasta/human_g1k_v37.fasta work/inputs
cp /projects/b1049/genetics_refs/fasta/human_g1k_v37.fasta.fai work/inputs

# copy over input bam's and indices
sample_name="sample"
cp "${sample_name}.bam" "${sample_name}.bam.bai" work/inputs

# download the parliament2_latest.sif (Singularity container)
cd work
module load singularity
singularity pull shub://sameerd/parliament2
```

2. Run Singularity container

```shell
#!/bin/bash

#MSUB -A b1042
#MSUB -l nodes=1:ppn=24
#MSUB -l walltime=01:00:00:00
#MSUB -q genomics
#MSUB -e errlog
#MSUB -j oe

module load singularity

cd "${PBS_O_WORKDIR}/work"

LANG= singularity run \
	-B `pwd`/input:/home/dnanexus/in:rw \
	-B `pwd`/output:/home/dnanexus/out:rw \
	parliament2_latest.sif   \
    	--bam sample.bam \
		--bai sample.bam.bai \
		-r human_g1k_v37.fasta \
		--fai human_g1k_v37.fasta.fai \
		--breakdancer --breakseq  --manta \
		--cnvnator --lumpy --genotype 
```


3. The directory `work/output/` should have all the results in it. 

4. (Optional). The [README.md](https://github.com/dnanexus/parliament2/blob/master/README.md) file has more options at the end that you can use. 

