#!/bin/bash
set -euo pipefail

# quality control of reads, removing any with an average quailty score less than 20

for FWD in ./data/raw/*_1.fastq; do echo $FWD; REV=${FWD/_1/_2}; echo $REV; OUTFWD=${FWD/raw/clean}; echo $OUTFWD; OUTREV=${REV/raw/clean}; echo $OUTREV; fastp --in1 $FWD --in2 $REV --out1 $OUTFWD --out2 $OUTREV --json /dev/null/ --html /dev/null --average_qual 20; done

# they are all saved in ./data/clean
