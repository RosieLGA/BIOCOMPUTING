#!/bin/bash
set -ueo pipefail

# load the flye module
module avail 
module load Flye/gcc-11.4.1/2.9.6

# create the output directory
mkdir -p ./assemblies/assembly_module

# use flye 
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/assembly_module

# navigate to the output directory
cd ./assemblies/assembly_module

# rename the 'assembly.fasta` to `module_assembly.fasta` and flye.log to module_flye.log

mv assembly.fasta module_assembly.fasta
mv flye.log module_flye.log

# remove the bloat files
# this removes everything except the files we want to keep

rm -r 00-assembly 10-consensus 20-repeat 30-contigger 40-polishing assembly_graph.gfa assembly_graph.gv assembly_info.txt params.json
