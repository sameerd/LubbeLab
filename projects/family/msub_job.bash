#!/bin/bash


if (( $# < 1 )) ; then
  echo "Usage: $0 script_filename"
  exit
fi

set -x

# assuming this gets set from the scripts directory
cwd=`pwd`

msub \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q short \
  -l walltime=01:00:00 \
  -l nodes=1:ppn=4 \
  -A b1042 \
  "$1"

