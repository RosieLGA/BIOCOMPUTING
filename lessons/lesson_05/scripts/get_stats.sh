#!/bin/bash 
set -ueo pipefail 

MAIN_DIR=${HOME}/BIOCOMPUTING/lessons/lesson_05
cd ${MAIN_DIR}

seqkit stats ./data/*.fastq

