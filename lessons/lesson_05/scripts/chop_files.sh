#!/bin/bash
set -ueo pipefail

# set project directory where files are found
# this is mine, but you will have to change it to the correct location for your project
MAIN_DIR="/sciclone/home/rlgeorgeambroc/BIOCOMPUTING/lessons/lesson_05"

# go to that location
cd ${MAIN_DIR}

# whatever commands got you a working for-loop
for i in ./data/*_R1_*.fastq
do 
FWD=${i}
REV=${FWD/_R1_/_R2_}
OUT=${FWD%%_*}_chopped.fastq
N=200

echo $FWD $REV $OUT $N

${MAIN_DIR}/scripts/interleave_chop.sh ${FWD} ${REV} ${OUT} ${N}
done
