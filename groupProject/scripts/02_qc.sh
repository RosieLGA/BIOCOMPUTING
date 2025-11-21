#!/bin/bash
#SBATCH --job-name=gp_Quality
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=rlgeorgeambroc@wm.edu               # change this!
#SBATCH -o /sciclone/home/rlgeorgeambroc/logs/gpQuality_%j.out # change this!
#SBATCH -e /sciclone/home/rlgeorgeambroc/logs/gpQuality_%j.err # change this!

set -ueo pipefail

SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/group_project"
DB_DIR="${SCR_DIR}/db"
DL_DIR="${PROJECT_DIR}/data/raw"
SRA_DIR="${SCR_DIR}/SRA"
QC_DIR="${PROJECT_DIR}/data/clean"

mkdir -p "$QC_DIR"

for fwd in ${DL_DIR}/*_1.fastq.gz;do rev=${fwd/_1.fastq.gz/_2.fastq.gz};outfwd=${fwd/$DL_DIR/$QC_DIR}; outrev=${rev/$DL_DIR/$QC_DIR}; outfwd=${outfwd/.fastq.gz/_qc.fastq.gz}; outrev=${outrev/.fastq.gz/_qc.fastq.gz};fastp -i $fwd -o $outfwd -I $rev -O $outrev -j /dev/null -h /dev/null -n 0 -l 100 -e 20;done
# all QC files will be in $QC_DIR and have *_qc.fastq.gz naming pattern
