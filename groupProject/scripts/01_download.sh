#!/bin/bash
#SBATCH --job-name=download
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=rlgeorgeambroc@wm.edu               # change this!
#SBATCH -o /sciclone/home/rlgeorgeambroc/logs/download_%j.out # change this!
#SBATCH -e /sciclone/home/rlgeorgeambroc/logs/download_%j.err # change this!

set -ueo pipefail

# get conda
N_CORES=6
module load miniforge3
eval "$(conda shell.bash hook)"

# DOWNLOAD RAW READS #############################################################

# set filepath vars
SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/group_project"
DB_DIR="${SCR_DIR}/db"
DL_DIR="${PROJECT_DIR}/data/raw"
SRA_DIR="${SCR_DIR}/SRA"

# if SRA_DIR doens't exist, create it
[ -d "$SRA_DIR" ] || mkdir -p "$SRA_DIR"


# download the accession(s) listed in `./data/accessions.txt`
# only if they don't exist
for ACC in $(cat ./data/accessions.txt)
do

if [ ! -f "${SRA_DIR}/${ACC}/${ACC}.sra" ]; then
prefetch --output-directory "${SRA_DIR}" "$ACC"
fasterq-dump "${SRA_DIR}/${ACC}/${ACC}.sra" --outdir "$DL_DIR" --skip-technical --force --temp "${SCR_DIR}/tmp"
fi

done


# compress all downloaded fastq files (if they haven't been already)
if ls ${DL_DIR}/*.fastq >/dev/null 2>&1; then
gzip ${DL_DIR}/*.fastq
fi

# DOWNLOAD DATABASES #############################################################

# metaphlan is easiest to use via conda
# and metaphlan can install its own database to use
conda env list | grep -q '^metaphlan4-env' || mamba create -y -n metaphlan4-env -c bioconda -c conda-forge metaphlan

# look for the metaphlan database, only download if it does not exist already
if [ ! -f "${DB_DIR}/metaphlan/mpa_latest" ]; then
conda activate metaphlan4-env
# install the metaphlan database using N_CORES
# N_CORES is set in the pipeline.slurm script
metaphlan --install --db_dir "${DB_DIR}/metaphlan" --nproc $N_CORES
conda deactivate
fi


# prokka (also using conda, also installs its own database)
conda env list | grep -q '^prokka-env' || mamba create -y -n prokka-env -c conda-forge -c bioconda prokka
conda activate prokka-env
export PROKKA_DB=${DB_DIR}/prokka
prokka --setupdb --dbdir $PROKKA_DB
conda deactivate
