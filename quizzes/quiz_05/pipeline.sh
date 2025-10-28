#!/bin/bash
set -ueo pipefail

# Run script 1 named 01_prep_data.sh
# This script creates data folders (raw and clean), downloads data 
# and moves the files to raw and unzips it


./scripts/01_prep_data.sh


# Run script 2 named 02_get_stats.sh
# this  script uses seqkit 

./scripts/02_get_stats.sh

# RUn script 3 named 03_cleanup.sh



./scripts/03_cleanup.sh
