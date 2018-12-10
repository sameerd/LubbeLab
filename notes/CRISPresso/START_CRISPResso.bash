module load python/anaconda
module load bowtie
module load samtools
module load R

CRISPRESSO_DIR=/projects/b1049/genetics_programs/CRISPResso

export PYTHONPATH="${CRISPRESSO_DIR}${PYTHONPATH}"
export PATH="${CRISPRESSO_DIR}/CRISPResso_dependencies/bin:${PATH}"
export LD_LIBRARY_PATH="${CRISPRESSO_DIR}/CRISPResso_dependencies/lib:${LD_LIBRARY_PATH}"
