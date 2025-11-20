#!/bin/bash

set -ueo pipefail

# build out data and output structure in scratch directory

## set scratch space for data IO
SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC

## set project directory in scratch space
PROJECT_DIR="${SCR_DIR}/group_project"

## set database directory
DB_DIR="${SCR_DIR}/db"

## make directories for this project
mkdir -p "${PROJECT_DIR}/data/raw"
mkdir -p "${PROJECT_DIR}/data/clean"
mkdir -p "${PROJECT_DIR}/output"
mkdir -p "${DB_DIR}/metaphlan"
mkdir -p "${DB_DIR}/prokka"
