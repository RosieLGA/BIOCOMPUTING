#!/bin/bash
set -ueo pipefail

# I am setting my directory to where I will house my raw data
MAIN_DIR=${HOME}/BIOCOMPUTING/assignments/assignment_05/data/raw
cd ${MAIN_DIR}

# Downland the data from the provided link
wget https://gzahn.github.io/data/fastq_examples.tar

# Extract the contents
tar -xf fastq_examples.tar

# And clean up the `fastq_examples.tar` file
rm fastq_examples.tar
