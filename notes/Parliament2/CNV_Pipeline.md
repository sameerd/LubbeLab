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
3. Run **SURVIVOR** across samples, annotate calls with gnomAD and genecode data. 
   1. [Annotation/Extract Script (Bash)](../../projects/family/scripts/run_survivor_across_samples.bash)
   2. [Annotation/Extract Script (Python)](../../projects/family/scripts/survivor_extract.py)

---

### Output

The output looks something like this. 

| CHROM | POS      | END      | SURV\_TYPE | SVLEN | QUAL | SUPP\_VEC | SS4009013 | SS4009014 | SS4009015 | SS4009016 | SS4009013\_SUPP | SS4009014\_SUPP | SS4009015\_SUPP | SS4009016\_SUPP | NUM\_ANN | gene\_id              | gene\_name | gene\_type      | MDSGENE | NAME                | SVTYPE | FREQ\_HOMREF | FREQ\_HET | FREQ\_HOMALT | PROTEIN\_CODING\_\_LOF | PROTEIN\_CODING\_\_DUP\_LOF | PROTEIN\_CODING\_\_COPY\_GAIN | PROTEIN\_CODING\_\_DUP\_PARTIAL | PROTEIN\_CODING\_\_MSV\_EXON\_OVR | PROTEIN\_CODING\_\_INTRONIC | PROTEIN\_CODING\_\_INV\_SPAN | PROTEIN\_CODING\_\_UTR | PROTEIN\_CODING\_\_NEAREST\_TSS | PROTEIN\_CODING\_\_INTERGENIC | PROTEIN\_CODING\_\_PROMOTER | 
|-------|----------|----------|-----------|-------|------|----------|-----------|-----------|-----------|-----------|----------------|----------------|----------------|----------------|---------|----------------------|-----------|----------------|---------|---------------------|--------|-------------|----------|-------------|---------------------|-------------------------|---------------------------|-----------------------------|------------------------------|--------------------------|--------------------------|---------------------|-----------------------------|----------------------------|--------------------------| 
| chr1  | 3560241  | 3560976  | DEL       | -662  | 5    | 1001     | 0/1       | ./.       | ./.       | 1/1       | v100110        | vNaN           | vNaN           | v100110        | 1       | ENSG00000116213.15\_2 | WRAP73    | protein\_coding | FALSE   | NA                  | NA     | NA          | NA       | NA          | NA                  | NA                      | NA                        | NA                          | NA                           | NA                       | NA                       | NA                  | NA                          | NA                         | NA                       | 
| chr1  | 16376518 | 16386260 | DEL       | -9741 | 6    | 1001     | 0/1       | ./.       | ./.       | 0/1       | v010101        | vNaN           | vNaN           | v010101        | 3       | ENSG00000184908.17\_2 | CLCNKB    | protein\_coding | FALSE   | gnomAD\_v2\_INS\_1\_567 | INS    | 0.19        | 0.80     | 0.01        | NA                  | NA                      | NA                        | NA                          | NA                           | CLCNKB                   | NA                       | NA                  | NA                          | FALSE                      | NA                       | 
| chr1  | 16376518 | 16386260 | DEL       | -9741 | 6    | 1001     | 0/1       | ./.       | ./.       | 0/1       | v010101        | vNaN           | vNaN           | v010101        | 3       | ENSG00000185519.8\_2  | FAM131C   | protein\_coding | FALSE   | gnomAD\_v2\_INS\_1\_567 | INS    | 0.19        | 0.80     | 0.01        | NA                  | NA                      | NA                        | NA                          | NA                           | CLCNKB                   | NA                       | NA                  | NA                          | FALSE                      | NA                       | 


---

### Installation

**Parliament2 installation**.
Detailed instructions are [here](./RUN_Parliament2.md).

**SURVIVOR Installation**
Straightforward from the github websites. 

