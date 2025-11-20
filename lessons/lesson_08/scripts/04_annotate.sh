#!/bin/bash
#SBATCH --job-name=MG_Annotate
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=600 # asking for ten hours since each should only take ~30-60 minutes
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=rlgeorgeambroc@wm.edu               # change this!
#SBATCH -o /sciclone/home/rlgeorgeambroc/logs/annotate_%j.out # change this!
#SBATCH -e /sciclone/home/rlgeorgeambroc/logs/annotate_%j.err # change this!


# set filepath vars
SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/mg_assembly_08"
DB_DIR="${SCR_DIR}/db"
DL_DIR="${PROJECT_DIR}/data/raw"
SRA_DIR="${SCR_DIR}/SRA"
CONTIG_DIR="${PROJECT_DIR}/contigs"
ANNOT_DIR="${PROJECT_DIR}/annotations"
mkdir -p $ANNOT_DIR

# load prokka
module load miniforge3
eval "$(conda shell.bash hook)"
conda activate prokka-env

# looping through those raw filenames again like before
for fwd in ${DL_DIR}/*1_qc.fastq.gz
do

# derive input and output variables
rev=${fwd/_1_qc.fastq.gz/_2_qc.fastq.gz}
filename=$(basename $fwd)
samplename=$(echo ${filename%%_*})
contigs=$(echo ${CONTIG_DIR}/${samplename}/contigs.fasta)
outdir=$(echo ${ANNOT_DIR}/${samplename})

# run prokka to predict and annotate genes
prokka $contigs --outdir $outdir --prefix $samplename --cpus 20 --kingdom Bacteria --metagenome --locustag $samplename --force

# this will make a new directory in $outdir and populate it with result files named $samplename.***

done

conda deactivate && conda deactivate
