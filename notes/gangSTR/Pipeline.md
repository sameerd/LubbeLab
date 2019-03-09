[GangSTR](https://github.com/gymreklab/GangSTR) is a tool for profiling long
STRs from short reads. 


### Pipeline Steps
1. [Quest Script (Bash)](../../projects/family/data/input/gangstr/submit_jobs.bash). This script starts with the `bam` files and runs `gangSTR` to get a vcf file with STR candidates. Then it filters the candidates with `dumpSTR`. 
2. [Extract Script (Python)](../../projects/family/scripts/gangstr_extract.py). This script extracts out information from the resulting filtering vcf files for further processing. \
*Requirements* :
    * Python 2 or 3 
3. [Filtering/annotation Script (R)](../../projects/family/scripts/gangstr_filter_family3.R). This script filters the output of the previous step on disease pattern and it also annotates with `annovar`. \
*Requirements* : 
    * R/3.5.1 
    * `tidyverse` package and subpackages.

---

### Output

The output looks something like this. 

| Chr  | Start     | End       | Func.refGene | Gene.refGene        | GeneDetail.refGene       | ExonicFunc.refGene | AAChange.refGene | superDupsScore | RU | REF | SS13\_NUM | SS13\_GT | SS13\_CI\_1\_L | SS13\_CI\_1\_U | SS13\_CI\_2\_L | SS13\_CI\_2\_U | SS13\_RC    | SS14\_NUM | SS14\_GT | SS14\_CI\_1\_L | SS14\_CI\_1\_U | SS14\_CI\_2\_L | SS14\_CI\_2\_U | SS14\_RC   | SS15\_NUM | SS15\_GT | SS15\_CI\_1\_L | SS15\_CI\_1\_U | SS15\_CI\_2\_L | SS15\_CI\_2\_U | SS15\_RC   | SS16\_NUM | SS16\_GT | SS16\_CI\_1\_L | SS16\_CI\_1\_U | SS16\_CI\_2\_L | SS16\_CI\_2\_U | SS16\_RC    | SingleRefGene | 
|------|-----------|-----------|--------------|---------------------|--------------------------|--------------------|------------------|----------------|----|-----|----------|---------|-------------|-------------|-------------|-------------|------------|----------|---------|-------------|-------------|-------------|-------------|-----------|----------|---------|-------------|-------------|-------------|-------------|-----------|----------|---------|-------------|-------------|-------------|-------------|------------|---------------| 
| chr3 | 155488752 | 155488781 | intronic     | C3orf33             | .                        | .                  | .                | .              | tg | 15  | 15,21    | 0/1     | 15          | 15          | 21          | 21          | 19,70,0,12 | 15,17    | 0/1     | 15          | 17          | 17          | 17          | 25,22,0,7 | 18,20    | 1/2     | 18          | 18          | 18          | 20          | 16,21,0,8 | 17,21    | 1/2     | 17          | 17          | 21          | 21          | 15,25,0,10 | C3orf33       | 
| chr4 | 61204002  | 61204013  | intergenic   | LINC02429;MIR548AG1 | dist=1291325;dist=584324 | .                  | .                | .              | tc | 6   | 7,8      | 1/2     | 7           | 8           | 8           | 8           | 8,30,0,0   | 6,6      | 0/0     | 6           | 6           | 6           | 6           | 6,23,0,0  | 6,7      | 0/1     | 6           | 6           | 6           | 7           | 8,27,0,0  | 6,8      | 0/1     | 6           | 8           | 8           | 8           | 7,27,0,0   | LINC02429     | 


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

```shell
git clone https://github.com/gymreklab/STRTools
module load anaconda3
PYTHONPATH=/projects/b1049/genetics_programs/gangSTR/lib/python3.7/site-packages/ python setup.py install --prefix=/projects/b1049/genetics_programs/gangSTR
```

