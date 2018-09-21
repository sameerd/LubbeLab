#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

java -jar /projects/b1049/genetics_programs/beagle/beagle.10Sep18.879.jar \
        gt=${PRE_GEN_VCF} ref=data/working/chr1.1kg.phase3.v5a.b37.bref3 \
        out=data/working/beagle_test chrom=1

