#!/bin/bash
set -ueo pipefail

# load miniforge3
module load miniforge3

# source conda
source /sciclone/apps/miniforge3-24.9.2-0/etc/profile.d/conda.sh

# build a conda environment for Flye v2.9.6 called "flye-env"
mamba create -y -n flye-env -c bioconda -c conda-forge flye=2.9.6
conda activate flye-env

# test it out with flye -v
echo "flye -v"
flye -v
# Document the environment by exporting a yml file of all the dependencies and versions
conda env export --no-builds > flye-env.yml

