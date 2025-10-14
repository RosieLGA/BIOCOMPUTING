#!/bin/bash
set -ueo pipefail

# Download the small genomic dataset
wget https://zenodo.org/records/15730819/files/SRR33939694.fastq.gz

# and move the data to the ./data folder
mv *fastq.gz ./data
