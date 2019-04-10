The CNV pipeline uses a consensus caller
[Parliament2](https://github.com/dnanexus/parliament2) which calls Manta,
Lumpy, Delly2, CNVNator, Breakdancer, Breakseq2 and combines their results.
Then [SURVIVOR](https://github.com/fritzsedlazeck/SURVIVOR) is used to combine
the results across samples and
[SURVIVOR\_ant](https://github.com/fritzsedlazeck/SURVIVOR_ant) is used to
annotate the calls with [structural variant data from
gnomAD](https://macarthurlab.org/2019/03/20/structural-variants-in-gnomad/).


### Pipeline Steps
1. Run **Parliament2** on the `bam` files. This step uses [Cromwell](https://software.broadinstitute.org/wdl/). The are several pieces
   1. [Cromwell task script (WDL)](../../cromwell/task_pipelines/parliament2.wdl)
   2. [Cromwell pipeline script (WDL)](../../cromwell/parliament2_pipeline.wdl)
   3. [Cromwell submit script (Bash)](../../projects/family/cromwell/parliament2_submit.bash)
2. Run **SURVIVOR** on raw Parliament output to get calls supported by atleast 3 callers.
   1. [SURVIVOR Script (Bash)](../../projects/family/scripts/run_survivor.bash). 
3. Run **SURVIVOR** across samples, annotate calls with gnomAD data. 
   1. [Annotation/Extract Script (Bash)](../../projects/family/scripts/run_survivor_across_samples.bash)
   2. [Annotation/Extract Script (Python)](../../projects/family/scripts/survivor_extract.py)

---

### Output

The output looks something like this. 

| CHROM | POS      | END      | SURV\_TYPE | SVLEN | QUAL | SUPP\_VEC | SS4009021 | SS4009023 | SS4009030 | SS4009021\_SUPP | SS4009023\_SUPP | SS4009030\_SUPP | NUM\_ANN | MDSGENE | NAME                 | SVTYPE | FREQ\_HOMREF | FREQ\_HET | FREQ\_HOMALT | PROTEIN\_CODING\_\_LOF | PROTEIN\_CODING\_\_DUP\_LOF | PROTEIN\_CODING\_\_COPY\_GAIN | PROTEIN\_CODING\_\_DUP\_PARTIAL | PROTEIN\_CODING\_\_MSV\_EXON\_OVR | PROTEIN\_CODING\_\_INTRONIC | PROTEIN\_CODING\_\_INV\_SPAN | PROTEIN\_CODING\_\_UTR | PROTEIN\_CODING\_\_NEAREST\_TSS | PROTEIN\_CODING\_\_INTERGENIC | PROTEIN\_CODING\_\_PROMOTER | 
|-------|----------|----------|-----------|-------|------|----------|-----------|-----------|-----------|----------------|----------------|----------------|---------|---------|----------------------|--------|-------------|----------|-------------|---------------------|-------------------------|---------------------------|-----------------------------|------------------------------|--------------------------|--------------------------|---------------------|-----------------------------|----------------------------|--------------------------| 
| chr1  | 26489350 | 26490139 | DEL       | -407  | 10   | 101      | 0/1       | ./.       | 0/1       | v010101        | vNaN           | v110101        | 0       | NA      | NA                   | NA     | NA          | NA       | NA          | NA                  | NA                      | NA                        | NA                          | NA                           | NA                       | NA                       | NA                  | NA                          | NA                         | NA                       | 
| chr1  | 42743187 | 42743503 | DEL       | -386  | 10   | 101      | 0/1       | ./.       | 0/1       | v110101        | vNaN           | v110111        | 1       | FALSE   | gnomAD\_v2\_DEL\_1\_3727 | DEL    | 0.09        | 0.77     | 0.15        | NA                  | NA                      | NA                        | NA                          | NA                           | FOXJ3                    | NA                       | NA                  | NA                          | FALSE                      | NA                       | 


---

### Installation

**Parliament2 installation**.
Detailed instructions are [here](./RUN_Parliament2.md).

**SURVIVOR Installation**
Straightforward from the github websites. 

