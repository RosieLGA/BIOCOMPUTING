#!/bin/bash
set -ueo pipefail

# run ./scripts/02_flye_2.9.6_manual_build.sh
./scripts/02_flye_2.9.6_manual_build.sh

# make sure Flye is added to your path
export PATH="$HOME/programs/Flye/bin:$PATH"

# create the output directory
mkdir -p ./assemblies/assembly_local

# use flye 
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/assembly_local

# navigate to the output directory
cd ./assemblies/assembly_local

# Check that assembly.fasta exists and is non-empty. I kept getting an error saying that assembly.fasta did not exist but it did when I checked my folder. The script wont move on until the file is written.
if [[ ! -s assembly.fasta ]]; then
    echo "ERROR: assembly.fasta not found or empty!"
    exit 1
fi

# rename the 'assembly.fasta` to `local_assembly.fasta` and flye.log to local_flye.log

mv assembly.fasta local_assembly.fasta
mv flye.log local_flye.log

# remove the bloat files
# this removes everything except the files we want to keep

rm -r 00-assembly 10-consensus 20-repeat 30-contigger 40-polishing assembly_graph.gfa assembly_graph.gv assembly_info.txt params.json
