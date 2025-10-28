### Rosie George-Ambrocio
### October 26, 2025
### Assignment 07

## Start off by signing into the hpc. Login into the bora server via ssh

```
ssh yourID@bora.sciclone.wm.edu
cd BIOCOMPUTING
ls
```

### For this assignment, I prefer using local installs or modules for different programs. Outside of the directory housing my assignment_07 material, I have a folder called ~/programs where I have installed tools and programs added them to my $PATH. This includes:
## sra-toolkit https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
## datasets https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/
## fastp https://github.com/OpenGene/fastp?tab=readme-ov-file#or-download-the-latest-prebuilt-binary-for-linux-users
## samtools is available as a module
## I will also use bbmap, but that will be with a conda-env instead of a local install

### **Task 1** : Setup assignment_07 director
## Make directories for assemblies, data, and scripts

```
mkdir -p data/{clean,dog_reference,raw} output scripts
```

## And make a README.md for documentation

```
touch README.md
```

### **Task 2** : Download Sequence Data
## I wanted to look for sequence data about cow guts
## Here are my search terms from Oct 25,2025 : (("Bos taurus"[Organism] OR cow[All Fields]) AND gut[All Fields]) AND "bovine gut metagenome"[orgn] AND ("biomol dna"[Properties] AND "library layout paired"[Properties] AND "platform illumina"[Properties] AND "filetype fastq"[Properties])
## In the SRA run selector, I filter LibrarySelection to just include RANDOM. Afterwards, I downloaded the Metadata file named SraRunTable.csv
## Since the file went to my local computer, I moved SraRunTable.csv from there to the HPC (~/BIOCOMPUTING/assignments/assignment_7/data/) using FileZilla.

## This csv has a whole bunch of accessions, but I am just going to use the first 10. 

## Lets make the first script ./scripts/01_download_data.sh

```
nano ./scripts/01_download_data.sh
```

## Here is the contents of that script

```
#!/bin/bash
set -euo pipefail

# set up data directories
mkdir -p data/{clean,dog_reference,raw}

# download the sra accession files and put them in ./data/raw
# I am going to make a conditional statement so that if I need to rerun this to get some missing fastq files without having to redownload the ones I already have


for ACC in $(cat ./data/SraRunTable.csv | cut -d',' -f 1 | head -n 11 | tail -n +2);
do 
if [ ! -f "./data/raw/${ACC}_1.fastq" ]; then
        # File doesnt exist so download it
        fasterq-dump -O ./data/raw $ACC
    fi
done


# download reference dog genomem and put it in the ./data/dog_reference directory
# I am going to make another conditional statement so I dont redownload the reference if I already have it 

if [ ! -f "./data/dog_reference/dog.zip]; then
datasets download genome taxon "Canis familiaris" --reference --filename ./data/dog_reference/dog.zip;
unzip ./data/dog_reference/dog.zip -d ./data/dog_reference; 
fi
```
## make it executable and run it

```
chmod +x ./scripts/01_download_data.sh
./scripts/01_download_data.sh
```


### **Task 3** : Clean up raw reads
## Lets make the second script ./scripts/02_clean_read.sh

```
nano ./scripts/02_clean_reads.sh
```

## Here is the contents of that script

```
#!/bin/bash
set -euo pipefail

# quality control of reads, removing any with an average quailty score less than 20

for FWD in ./data/raw/*_1.fastq; do echo $FWD; REV=${FWD/_1/_2}; echo $REV; OUTFWD=${FWD/raw/clean}; echo $OUTFWD; OUTREV=${REV/raw/clean}; echo $OUTREV; fastp --in1 $FWD --in2 $REV --out1 $OUTFWD --out2 $OUTREV --json /dev/null/ --html /dev/null --average_qual 20; done

# they are all saved in ./data/clean

```
## make it executable and run it

```
chmod +x ./scripts/02_clean_reads.sh
./scripts/02_clean_reads.sh
```


### **Task 4** : Map clean reads to dog genome
## for this step, we will use a conda environment

## Lets make the third script ./scripts/03_map_reads.sh

```
nano ./scripts/03_map_reads.sh
```

## Here is the contents of that script

```
#!/bin/bash

set -euo pipefail

# Create variable for where the files are stored and where they need to go
# also make a logs directly since this is where I think things will get crazy
REF="./data/dog_reference/ncbi_dataset/data/GCF_011100685.1/GCF_011100685.1_UU_Cfam_GSD_1.0_genomic.fna"
OUTDIR="./output"
LOGDIR="./logs"
REFDIR="./data/dog_reference/index"
mkdir -p "$OUTDIR" "$LOGDIR" "$REFDIR"

echo "Reference genome: $REF"
echo "Output: $OUTDIR"
echo "Logs: $LOGDIR"

# Build the BBMap index once (if not already present)
if [ ! -f "$REFDIR/ref/genome/1/chr1.fa" ]; then
    echo "Building BBMap index..."
    bbmap.sh ref="$REF" path="$REFDIR" > "$LOGDIR/build_index.log" 2>&1
fi

# Loop through all clean reads
for FWD in ./data/clean/*_1.fastq; do
    BASE=$(basename "$FWD" _1.fastq)
    REV="./data/clean/${BASE}_2.fastq"
    OUT="${OUTDIR}/${BASE}_mapped_to_dog.sam"
    LOG="${LOGDIR}/${BASE}_bbmap.log"
    
 # Sanity Check (and I really need it)
    echo "Processing sample: $BASE"
    echo "  FWD: $FWD"
    echo "  REV: $REV"
    echo "  OUT: $OUT"

    # Run BBMap and put the out in ./output
    bbmap.sh ref="$REF" path="$REFDIR" in1="$FWD" in2="$REV" out="$OUT" minid=0.95 sam=1 noheader=f overwrite=t > "$LOG" 2>&1
done

```
## make it executable and run it

```
chmod +x ./scripts/03_map_reads.sh
./scripts/03_map_reads.sh
```

### **Task 5** : Extract reads that matched dog genome
## Lets make the add some more to the third script ./scripts/03_map_reads.sh

```
nano ./scripts/03_map_reads.sh
```

## Here is the new version of that script

```
#!/bin/bash

set -euo pipefail

# Create variable for where the files are stored and where they need to go
# also make a logs directly since this is where I think things will get crazy
REF="./data/dog_reference/ncbi_dataset/data/GCF_011100685.1/GCF_011100685.1_UU_Cfam_GSD_1.0_genomic.fna"
OUTDIR="./output"
LOGDIR="./logs"
REFDIR="./data/dog_reference/index"
mkdir -p "$OUTDIR" "$LOGDIR" "$REFDIR"

echo "Reference genome: $REF"
echo "Output: $OUTDIR"
echo "Logs: $LOGDIR"

# Build the BBMap index once (if not already present)
if [ ! -f "$REFDIR/ref/genome/1/chr1.fa" ]; then
    echo "Building BBMap index..."
    bbmap.sh ref="$REF" path="$REFDIR" > "$LOGDIR/build_index.log" 2>&1
fi

# Loop through all clean reads
for FWD in ./data/clean/*_1.fastq; do
    BASE=$(basename "$FWD" _1.fastq)
    REV="./data/clean/${BASE}_2.fastq"
    OUT="${OUTDIR}/${BASE}_mapped_to_dog.sam"
    LOG="${LOGDIR}/${BASE}_bbmap.log"
    
 # Sanity Check (and I really need it)
    echo "Processing sample: $BASE"
    echo "  FWD: $FWD"
    echo "  REV: $REV"
    echo "  OUT: $OUT"

    # Run BBMap and put the out in ./output
    bbmap.sh ref="$REF" path="$REFDIR" in1="$FWD" in2="$REV" out="$OUT" minid=0.95 sam=1 noheader=f overwrite=t > "$LOG" 2>&1
done


# use samtools to to extract any reads that had significant positive matches to the dog reference genome. the output files also go to ./output
for SAM in ./output/*_mapped_to_dog.sam; do
    OUT="${SAM/_mapped_to_dog.sam/_dog_match.sam}"
    echo "Filtering $SAM -> $OUT"
    samtools view -h -F 4 "$SAM" > "$OUT"
done
echo "Mapping and extracting finished"
```

### **Task 6** : Submit your job to SLURM

## Make a pipeline to submit to SLURM

```
nano assignment_7_pipeline.slurm
```

```
#!/bin/bash
#SBATCH --job-name=assignment_07
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=20 
#SBATCH --time=1-00:00:00 
#SBATCH --mail-type=FAIL,BEGIN,END 
#SBATCH --mail-user=rlgeorgeambroc@wm.edu
#SBATCH -o logs/assignment_07_%j.out 
#SBATCH -e logs/assignment_07_%j.err 

# set up enviroment
# load modules
module load miniforge3  
module load samtools/gcc-11.4.1/1.21 

# set up conda
source "$(dirname $(dirname $(which conda)))/etc/profile.d/conda.sh" 

# export any paths
export PATH=$PATH:$HOME/programs/sratoolkit.3.2.1-ubuntu64/bin
export PATH=$PATH:$HOME/programs

# Create bbmap-env if it doesn’t exist and activate conda

if ! conda info --envs | grep -q "bbmap-env"; then
    conda create -y -n bbmap-env bbmap -c bioconda
fi  
conda activate bbmap-env

echo "Downloading data"
# Script 1: Download sequence data
bash ./scripts/01_download_data.sh

echo "Cleaning reads"
# Script 2: Clean up raw reads
bash ./scripts/02_clean_reads.sh

echo "Mapping reads and extracting matches"
# Script 3: Map clean reads to dog genome and Extract reads that matched dog genome
bash ./scripts/03_map_reads.sh

# Deactivate conda environment
conda deactivate

```

## And lets run it! 
sbatch assignment_7_pipeline.slurm


### **Task 7** : Inspect your stdout and stderr
## Everything looks good!
## I sent these files to ./log instead of ./output to keep things nicely organized

### **Task 8** : Inspect your results
## I made a script to create a summary table of the results. It has a column for accession/sample number, number of quality reads (cleaned reads), and reads that mapped to the dog genome

```
nano ./scripts/04_summary_table.sh
```
## Here is the contents of that script

```
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
```
## Here is the output of that script
```
SampleID,QC_Reads,Mapped_Reads
SRR094166,17722506,201
SRR094403,17232814,225
SRR094405,17418094,207
SRR094415,17510272,161
SRR094416,17182602,184
SRR094417,18118484,208
SRR094418,17158340,209
SRR094419,114977768,2481
SRR094424,305806756,992
SRR094427,104712312,2291
```
### **Task 9** : Document Everything in README.md
## Reflection
# I had some trouble with my script 03_map_reads.sh when I first tested it with the first 10 reads from each sample. My *_mapped_to_dog.sam files I got when I did bbmap had absolutely nothing in them. When I ran samtools on them, I kept getting errors. It took me a good while to realize the reason I kept getting errors is cause bbmap did not map to anything. My *_mapped_to_dog.sam were blank with no headers. I ended up forcing it make headers by header=t in my bbmap command. 
# I learned a couple of new things. The biggest thing was to remember to load the environment I wanted to use. samtools was used in my 03_map_reads.sh and my 04_summary_table.sh. I kept forgetting to load it to use 04_summary_table.sh, so I eventually added "module load samtools" to the script itself. As I kept generating new files throughout the assignment, I also learned that directory structure is key. I used "tree" a lot during the assignment and it was crazy to just how much the contents within my project grew. 
