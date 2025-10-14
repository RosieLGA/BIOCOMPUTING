#!/bin/bash
set -ueo pipefail

# load conda and the flye-env
./scripts/02_flye_2.9.6_conda_install.sh

# create the output directory
mkdir -p ./assemblies/assembly_conda

# use flye 
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/assembly_conda

# navigate to the output directory
cd ./assemblies/assembly_conda

# rename the 'assembly.fasta` to `conda_assembly.fasta` and flye.log to conda_flye.log

mv assembly.fasta conda_assembly.fasta
mv flye.log conda_flye.log

# remove the bloat files
# this removes everything except the files we want to keep

rm -r 00-assembly 10-consensus 20-repeat 30-contigger 40-polishing assembly_graph.gfa assembly_graph.gv assembly_info.txt params.json 

# source conda
source /sciclone/apps/miniforge3-24.9.2-0/etc/profile.d/conda.sh

# deactivate the flye-env
conda deactivate
