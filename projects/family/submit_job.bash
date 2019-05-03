#!/bin/bash

# arguments that go into msub
allocation=""
queue=""
walltime=""
ppn=2

show_help () 
{

echo "Usage: $0 [OPTIONS] script_filename"

cat <<HEREDOC
This script will try and choose intelligent arguments for allocation and
walltime based on the queue variable.

Optional arguments
-A   : allocation (default: b1042)
-q   : queue (default: short)
-p   : processors per node (default: 2)
-w   : walltime (default: based on queue)
HEREDOC

}

set -x

OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "h?A:q:w:p:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    A)  allocation=$OPTARG
        ;;
    q)  queue=$OPTARG
        ;;
    p)  ppn=$OPTARG
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

if [ -z "$queue" ]; then queue="short"; fi
echo "Setting queue to : $queue"

if [ -z "$allocation" ]; then allocation="b1042"; fi
echo "Setting allocation to : $allocation"

case "$queue" in
  short)
    if [ -z "$walltime" ]; then walltime="01:00:00"; fi
    echo "Setting walltime to : $walltime"
    ;;
  genomics)
    if [ -z "$walltime" ]; then walltime="47:00:00"; fi
    echo "Setting walltime to : $walltime"
    ;;
  genomicslong)
    if [ -z "$walltime" ]; then walltime="168:00:00"; fi
    echo "Setting walltime to : $walltime"
    ;;
esac

# assuming this will get run from the scripts directory
cwd=`pwd`

sbatch \
  --error="${cwd}/logs/errlog.txt" \
  --output="${cwd}/logs/outlog.txt" \
  -D "${cwd}" \
  -p ${queue} \
  -t ${walltime} \
  -n 1 \
  --ntasks-per-node=${ppn} \
  -A ${allocation} \
  "$1"

