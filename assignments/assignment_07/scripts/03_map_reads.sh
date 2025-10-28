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


# use samtools to to extract any reads that had significant positive matches to the dog reference genome.  the output files also go to ./output
for SAM in ./output/*_mapped_to_dog.sam; do
    OUT="${SAM/_mapped_to_dog.sam/_dog_match.sam}"
    echo "Filtering $SAM -> $OUT"
    samtools view -h -F 4 "$SAM" > "$OUT"
done
echo "Mapping and extracting finished"
