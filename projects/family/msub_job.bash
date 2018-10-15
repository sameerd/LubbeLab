#!/bin/bash

# default arguments
allocation="b1042"
queue="short"
walltime="01:00:00"

show_help () 
{

echo "Usage: $0 [OPTIONS] script_filename"

cat <<HEREDOC
Optional arguments
-A   : allocation
-q   : queue
-w   : walltime
HEREDOC

}

set -x

OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "h?A:q:w:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    A)  allocation=$OPTARG
        ;;
    q)  queue=$OPTARG
        ;;
    w)  walltime=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [[ $# < 1 ]] ; then
  echo "Output file missing"
  show_help
  exit 1
fi

# assuming this will get run from the scripts directory
cwd=`pwd`

msub \
  -e "${cwd}/logs/errlog.txt" \
  -o "${cwd}/logs/outlog.txt" \
  -d "${cwd}" \
  -q ${queue} \
  -l ${walltime} \
  -l nodes=1:ppn=2 \
  -A ${allocation} \
  "$1"

