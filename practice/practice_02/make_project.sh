# !/bin/bash

# create directory structure
mkdir -p data/{clean,raw} output scripts

# create empty files
touch data/metadata.csv scripts/{01_QC.sh,02_assemble.sh,03_bin.sh,04_refine.sh,05_annotate.sh} README.md workflow.sh

# add lines to README.md
echo "# My new project" > README.md
echo ""
echo "Raw data are in ./data/raw"
echo ""
echo "All scripts are in ./scripts/"
echo ""
echo ".workflow.sh contains ordered instructions for runnning scripts"


