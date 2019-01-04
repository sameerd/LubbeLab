#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

awk 'NR > 7 {print}' "${SNP_CHIP_INPUT}" | \
  awk -F, \
    'BEGIN{OFS="\t"}
     NR == 1 {
       print $10, $11, $2, "Ref", "Alt"
     }
     NR > 1 {
       if ($10 != "" && $10 != 0) {
         match($4, "\\[([ACTG])/([ACTG])\\]", a); 
         print $10, $11, $2, a[1], a[2]
       }
    }' | \
  sort -k1 -k2 -V > "${SNP_CHIP_VARIANTS}"


