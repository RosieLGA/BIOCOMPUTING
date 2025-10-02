#!/bin/bash
set -ueo pipefail


# run ./scripts/01_download_data.sh to download data
./scripts/01_download_data.sh

# run a for-loop for all the newly downloaded data using ./scripts/02_run_fastp.sh

for i in ./data/raw/*_R1_*.fastq.gz
do
./scripts/02_run_fastp.sh "${i}"
done

# move the trimmed files to a different folder
mv ./data/raw/*trimmed* ./data/trimmed 

