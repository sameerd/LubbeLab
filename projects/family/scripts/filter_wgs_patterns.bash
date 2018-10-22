#!/bin/bash

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

awk -F"\t" '
    function gt(s) {
      split(s, a, ":"); 
      return a[1]; 
    }
    BEGIN {OFS="\t";}
    { 
      if($11 < 0.05) {
        print $1, $2, $3, $4, $5, $11, $28, gt($41), gt($43), gt($44);
      }
    }' \
  ${WORKINGDIR}/wgs_annovar.avinput.hg19_multianno.txt  | \
  grep -vP "0/0\t0/0\t0/0" | \
  grep -v "\./\." | grep "^chr1" > ${WORKINGDIR}/wgs_family2_patterns.txt
