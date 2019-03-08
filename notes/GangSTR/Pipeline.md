[GangSTR](https://github.com/gymreklab/GangSTR) is a tool for profiling long
STRs from short reads. 


### Pipeline Steps
1. [Quest Script (Bash)](../../projects/family/data/input/gangstr/submit_jobs.bash). This script starts with the `bam` files and runs `gangSTR` to get a vcf file with STR candidates. Then it filters the candidates with `dumpSTR`. 
2. [Extract Script (Python)](../../projects/family/scripts/gangstr_extract.py). This script extracts out information from the resulting filtering vcf files for further processing. \
Requirements :
    * Python 2 or 3 
3. [Filtering/annotation Script (R)](../../projects/family/scripts/gangstr_filter_family3.R). This script filters the output of the previous step on disease pattern and it also annotates with `annovar`. \
Requirements : 
    * R/3.5.1 
    * `tidyverse` package and subpackages.

---

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

