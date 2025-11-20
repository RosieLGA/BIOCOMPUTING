#!/bin/bash
#!/bin/bash
#SBATCH --job-name=REPLACEME_assembly
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=rlgeorgeambroc@wm.edu               # change this!
#SBATCH -o /sciclone/home/rlgeorgeambroc/logs/REPLACEME_%j.out # change this!
#SBATCH -e /sciclone/home/rlgeorgeambroc/logs/REPLACEME_%j.err # change this!



SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/mg_assembly_08"
DB_DIR="${SCR_DIR}/db"
DL_DIR="${PROJECT_DIR}/data/raw"
SRA_DIR="${SCR_DIR}/SRA"
CONTIG_DIR="${PROJECT_DIR}/contigs"

mkdir -p $CONTIG_DIR

for fwd in ${DL_DIR}/*REPLACEME*1_qc.fastq.gz
do

# derive input and output variables 
rev=${fwd/_1_qc.fastq.gz/_2_qc.fastq.gz}
filename=$(basemane $fwd)
samplename=$(echo ${filename%%_*})
outdir=$(echo ${CONTIG_DIR}/${samplename})

#run spades with mostly default options
spades.py -1 $fwd -2 $rev -o $outdir -t 20 --meta
done
