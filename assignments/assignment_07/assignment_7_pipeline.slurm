#!/bin/bash
#SBATCH --job-name=assignment_07
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=20 
#SBATCH --time=1-00:00:00 
#SBATCH --mail-type=FAIL,BEGIN,END 
#SBATCH --mail-user=rlgeorgeambroc@wm.edu
#SBATCH -o logs/assignment_07_%j.out 
#SBATCH -e logs/assignment_07_%j.err 

# set up enviroment
# load modules
module load miniforge3  
module load samtools/gcc-11.4.1/1.21 

# set up conda
source "$(dirname $(dirname $(which conda)))/etc/profile.d/conda.sh" 

# export any paths
export PATH=$PATH:$HOME/programs/sratoolkit.3.2.1-ubuntu64/bin
export PATH=$PATH:$HOME/programs

# Create bbmap-env if it doesn’t exist and activate conda

if ! conda info --envs | grep -q "bbmap-env"; then
    conda create -y -n bbmap-env bbmap -c bioconda
fi  
conda activate bbmap-env

echo "Downloading data"
# Script 1: Download sequence data
bash ./scripts/01_download_data.sh

echo "Cleaning reads"
# Script 2: Clean up raw reads
bash ./scripts/02_clean_reads.sh

echo "Mapping reads and extracting matches"
# Script 3: Map clean reads to dog genome and Extract reads that matched dog genome
bash ./scripts/03_map_reads.sh

# Deactivate conda environment
conda deactivate
