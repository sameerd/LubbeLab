#!/bin/bash

set -x

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash


python scripts/filter_annovar_output.py \
        "${ANNOVAR_OUTPUT}" \
        "${ANNOVAR_HEADERS}" \
       > "${ANNOVAR_FILTERED}" 

