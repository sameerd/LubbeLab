[GangSTR](https://github.com/gymreklab/GangSTR) is a tool for profiling long
STRs from short reads. 


### Pipeline steps
1. Start with the `bam` files and apply gangSTR to get a vcf file with STR candidates. Then filter the candidates with `dumpSTR`. The quest submission script is at 
   [Quest Script (Bash)](../../projects/family/data/input/gangstr/submit_jobs.bash)
2. Extract out information from the resulting filtering vcf files for further processing. The extract script is at  
   [Extract Script (Python)](../../projects/family/scripts/gangstr_extract.py)
3. Filter on disease pattern and annotate. The filter script is at  
   [Filtering/annotation Script (R)](../../projects/family/scripts/gangstr_filter_family3.R)


### Installation

**Singularity installation**. Installs `gangSTR` and strtools like `dumpSTR`.

```shell
cd /projects/b1049/genetics_programs/gangSTR
singularity pull docker://gymreklab/str-toolkit
```

**Manual Installation**

```shell
cd /projects/b1049/genetics_programs/gangSTR
wget https://github.com/gymreklab/GangSTR/releases/download/v2.3/GangSTR-2.3.tar.gz
tar zxf GangSTR-2.3.tar.gz
cd GangSTR-2.3
./install-gangstr.sh `realpath .`
```

