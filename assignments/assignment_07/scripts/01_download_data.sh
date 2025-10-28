#!/bin/bash
set -euo pipefail

# set up data, output, and log directories
mkdir -p data/{clean,dog_reference,raw} output logs

# download the sra accession files and put them in ./data/raw
# I am going to make a conditional statement so that if I need to rerun this to get some missing fastq files without having to redownload the ones I already have


for ACC in $(cat ./data/SraRunTable.csv | cut -d',' -f 1 | head -n 11 | tail -n +2);
do 
if [ ! -f "./data/raw/${ACC}_1.fastq" ]; then
        # File doesnt exist so download it
        fasterq-dump -O ./data/raw $ACC
    fi
done


# download reference dog genome and put it in the ./data/dog_reference directory
# I am going to make another conditional statement so I dont redownload the reference if I already have it 

if [ ! -f "./data/dog_reference/dog.zip" ]; then
datasets download genome taxon "Canis familiaris" --reference --filename ./data/dog_reference/dog.zip;
unzip ./data/dog_reference/dog.zip -d ./data/dog_reference; 
fi
