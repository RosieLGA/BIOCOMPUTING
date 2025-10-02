#!/bin/bash
set -ueo pipefail

# set project directory where files are found

MAIN_DIR=${HOME}/BIOCOMPUTING/assignments/assignment_05/data/raw # where my raw data is
LOG_DIR=${HOME}/BIOCOMPUTING/assignments/assignment_05/log # where my html files will be housed

# making my variables from reads

FWD_IN=${1} # the forward read input

REV_IN=${FWD_IN/_R1_/_R2_} # the reverse read input, replaces _R1_ occurrence with _R2_

FWD_OUT=${FWD_IN/.fastq.gz/.trimmed.fastq.gz} # the trimmed forward read output, replaces .fastq.gz with .trimmed.fastq.gz in the forward read input filename

REV_OUT=${REV_IN/.fastq.gz/.trimmed.fastq.gz} # the trimmed reverse read output, replaces .fastq.gz with .trimmed.fastq.gz in the reverse read input filename


# Direct my html files to go to ./assignment_05/log/

FILENAME="${FWD_IN##*/}" # create a FILENAME variable by just getting the filename by matching everything up to the last / and remove the longest match from the start

SAMPLE="${FILENAME%%_R1_*}" # Creates a SAMPLE variable that is just the part of the filename before _R1_

HTML_OUT="${LOG_DIR}/${SAMPLE}_fastp.html" # creates a path for my html output. It places the html file in the ./log folder and names the html by the SAMPLE name and adds _fastp.html to the end of the name

# This is a check-point for the script. 
echo "$SAMPLE"


# running fastp on the read files
# This is what I am doing in order: path/name of output fwd read, path/name of input rev read, path/name of output rev read, path/name of JSON report (none), path/name of HTML report(goes to ./log/), removes first 8 bases from fwd, removes first 8 bases from rev, removes last 20 bases from fwd, removes last 20 bases from rev, discards any reads with "N", discards reads shorter than 100nt, discards reads <20 avg quality

fastp \
  --in1 "$FWD_IN" \
  --in2 "$REV_IN" \
  --out1 "$FWD_OUT" \
  --out2 "$REV_OUT" \
  --json /dev/null \
  --html "$HTML_OUT" \
  --trim_front1 8 \
  --trim_front2 8 \
  --trim_tail1 20 \
  --trim_tail2 20 \
  --n_base_limit 0 \
  --length_required 100 \
  --average_qual 20

