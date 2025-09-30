#!/bin/bash
set -ueo pipefail

# change as needed
MAIN_DIR=${HOME}/BIOCOMPUTING/lessons/lesson_05
INSTALL_DIR=${HOME}/programs
DATA_DIR=${MAIN_DIR}/data
SCRIPTS_DIR=${MAIN_DIR}/scripts


# go to data directory for lesson (where all fastq files are)
cd ${DATA_DIR}

# run first script:
echo "chopping and interleaving files"
${SCRIPTS_DIR}/chop_files.sh # relative path to script

# go to install directory to run step 2
cd ${INSTALL_DIR}
# run step 2 from there (gotta append the location since you're not in that directory right now!)
echo "installing and unpacking seqkit"
${SCRIPTS_DIR}/install_seqkit.sh # relative path to script

# go back to your data location
cd ${DATA_DIR}

# run final step
echo "running seqkit stats on files"
${SCRIPTS_DIR}/get_stats.sh
