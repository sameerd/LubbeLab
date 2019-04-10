#!/bin/bash


#run Survivor for each sample and only extract calls supported by three callers 

module load singularity

source ./scripts/global_variables.bash
source ./scripts/project_variables.bash

echo ${OUTPUTDIR}

# create a directory for file that are supported by three callers
mkdir -p "${SUPP3DIR}"

# read all the files in the svtyped_vcf directory and extract out all IDs
mapfile -t id_array < <(ls ${PARLIAMENT_INPUTDIR}/svtyped_vcfs/* | grep -oP "SS400[0-9]*" | sort | uniq)
#printf '%s\n' "${id_array[@]}" 

# script that we use inside the parliament container to 
# redo the survivor command to only keep calls supported by 3 callers
# These lines below are modified from https://github.com/dnanexus/parliament2/blob/37d6306530cccbb61d503e070fb50b8e85405f56/parliament2.sh

cat <<'EOF' > "${SUPP3DIR}/survivor_supp3.bash"
#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Need the prefix argument'
    exit 1
fi

prefix=$1

# Run SURVIVOR
echo "Running SURVIVOR"
survivor merge "${prefix}_inputs.txt" 1000 3 1 0 0 10 "${prefix}.survivor.output.vcf"

# Prepare SURVIVOR outputs for upload
vcf-sort -c > "${prefix}.survivor_sorted.vcf" < "${prefix}.survivor.output.vcf"

sed -i 's/SAMPLE/breakdancer/g' "${prefix}.survivor_sorted.vcf"

python /combine_combined.py "${prefix}.survivor_sorted.vcf" \
    "${prefix}" "${prefix}_inputs.txt" /all.phred.txt \
        | python /correct_max_position.py > "${prefix}".combined.genotyped.vcf
EOF

chmod +x "${SUPP3DIR}/survivor_supp3.bash"
 

mkdir -p "${SUPP3DIR}/input"

# Merge the various caller results so that we have one file per ID. 
# The default Parliament output gives us the entire results. Here we
# want to ensure that we have atleast three callers per variant in each sample.
for id in "${id_array[@]}"
do
    echo "Processing $id alone"
    cd ${PARLIAMENT_INPUTDIR}/svtyped_vcfs
      #copy over the input files
      cp $id* "${SUPP3DIR}/input/"
      # create a file with the list of input files 
      ls $id* | sed 's/^/\/home\/dnanexus\/in\//' > "${SUPP3DIR}/${id}_inputs.txt"
    cd -

    cd "${SUPP3DIR}"
    TMPDIR=/tmp LANG= singularity exec \
            -B `pwd`/input:/home/dnanexus/in:rw \
            ${PARLIAMENT2} \
            ./survivor_supp3.bash "$id"
    cd -
done
