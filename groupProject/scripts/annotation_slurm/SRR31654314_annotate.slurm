#!/bin/bash
#SBATCH --job-name=SRR31654314_Annotate
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00 # each should only take ~30-60 minutes
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=rlgeorgeambroc@wm.edu               # change this!
#SBATCH -o /sciclone/home/rlgeorgeambroc/logs/SRR31654314_anno_%j.out # change this!
#SBATCH -e /sciclone/home/rlgeorgeambroc/logs/SRR31654314_anno_%j.err # change this!

set -ueo pipefail

# set filepath vars
SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/group_project"
DB_DIR="${SCR_DIR}/db"
QC_DIR="${PROJECT_DIR}/data/clean"
SRA_DIR="${SCR_DIR}/SRA"
CONTIG_DIR="${PROJECT_DIR}/contigs"
ANNOT_DIR="${PROJECT_DIR}/annotations"

# load prokka
module load miniforge3
eval "$(conda shell.bash hook)"
conda activate prokka-env


for fwd in ${QC_DIR}/*SRR31654314*1_qc.fastq.gz
do

# derive input and output variables
rev=${fwd/_1_qc.fastq.gz/_2_qc.fastq.gz}
filename=$(basename $fwd)
samplename=$(echo ${filename%%_*})
contigs=$(echo ${CONTIG_DIR}/${samplename}/contigs.fasta)
outdir=$(echo ${ANNOT_DIR}/${samplename})
contigs_safe=${contigs/.fasta/.safe.fasta}

# rename fasta headers to account for potentially too-long names (or spaces)
seqtk rename <(cat $contigs | sed 's/ //g') contig_ > $contigs_safe

# run prokka to predict and annotate genes
prokka $contigs_safe --outdir $outdir --prefix $samplename --cpus 20 --kingdom Bacteria --metagenome --locustag $samplename --force

done

conda deactivate && conda deactivate
