#!/bin/bash

SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/mg_assembly_08"
DB_DIR="${SCR_DIR}/db"
DL_DIR="${PROJECT_DIR}/data/raw"
SRA_DIR="${SCR_DIR}/SRA"

for fwd in ${DL_DIR}/*_1.fastq.gz;do rev=${fwd/_1.fastq.gz/_2.fastq.gz};outfwd=${fwd/.fastq.gz/_qc.fastq.gz};outrev=${rev/.fastq.gz/_qc.fastq.gz};fastp -i $fwd -o $outfwd -I $rev -O $outrev -j /dev/null -h /dev/null -n 0 -l 100 -e 20;done

# all QC files will be in $DL_DIR and have *_qc.fastq.gz naming pattern
