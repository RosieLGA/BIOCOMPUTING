#!/bin/bash
set -euo pipefail

module load samtools

# Make some headers on the table. This is just the header row
# This all goes on a file called summary.csv
echo -e "SampleID,QC_Reads,Mapped_Reads" > summary.csv

# Add information for each accession to the table 
for FWD in data/raw/*_1.fastq; do
    SAMPLE=$(basename "$FWD" _1.fastq) # the sample ID number
    CLEAN_FWD="./data/clean/${SAMPLE}_1.fastq" # the clean forward reads
    CLEAN_REV="./data/clean/${SAMPLE}_2.fastq" # the clean reverse reads
    MATCH="./output/${SAMPLE}_dog_match.sam" # the reads that matched to dog genome

    # count total reads in both pairs 
    # $(( ... )) makes Bash do math to add the lines in the FWD and REV reads
    # divide by 4 since one sequence takes up 4 lines
    QC_READS=$(( ($(wc -l < "$CLEAN_FWD") + $(wc -l < "$CLEAN_REV")) / 4 ))

    # count mapped reads using samtools
    MAPPED_READS=$(samtools view -c "$MATCH")
    
    # add the information for each sample to the summary.csv
    echo -e "${SAMPLE},${QC_READS},${MAPPED_READS}" >> summary.csv
done
