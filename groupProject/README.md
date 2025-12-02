### Rosie George-Ambrocio
### December 2, 2025
### Group Project

## Start off by signing into the hpc. Login into the bora server via ssh

```
ssh yourID@bora.sciclone.wm.edu
cd BIOCOMPUTING
mkdir -p groupProject
```

## Set my directory to groupProject

```
cd ./groupProject
```

## Make directories for assemblies, data, and scripts

```
mkdir -p output data scripts
```

## And make a README.md for documentation

```
touch README.md
```
## and the scripts we will use

```
cd scripts

touch 00_setup.sh 01_download.sh 02_qc.sh 03_assemble_template.sh 04_annotate_template.sh 05_coverage.sh

chmod +x *
```

## Script 00_setup.sh will set up directories in scratch space so that we can put big data files there. The scripts we make in the main groupProject directory will work within the group_project directory in scr10

```
nano 00_setup.sh
```
### Here is the content of the script

```
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
```
## To run this script, use the following, 

```
./00_setup.sh
```

## Script 01_download.sh will download the data for this project and create the database directories for metaphlan and prokka. It will also build the environments.

## My group used 10 samples from this bioproject on ncbi https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1195999
## My group did not pick large samples since it would take longer to work with. Instead, we aimed for samples between 1e^09 to 2e^09 and samples that had a spot length of at least 100. 

## We placed the chosen accession number on groupProject/data

```
cd ..
cd data
nano accessions.txt
```

## We used the following accession numbers:
### SRR31654314 SRR31654324 SRR31654305 
### SRR31654343 SRR31654339 SRR31654352 SRR31654355 
### SRR31654385 SRR31654365 SRR31654382
## The first line of accession numbers are samples from young-old people (60-74 years old), the second line is from middle-old people (75-89 years old), and the third line is from long-lived old people (90-99 years old). A table with this information is stored within my /groupProject/output directory as AccessionsTable.csv



```
cd ..
cd scripts
nano 01_download.sh
```

### Since the samples are large, I used a slurm job to download them. Here is the content of the script 01_download.sh 

```
#!/bin/bash
#SBATCH --job-name=download
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=USER@wm.edu               # change this!
#SBATCH -o /sciclone/home/USER/logs/download_%j.out # change this!
#SBATCH -e /sciclone/home/USER/logs/download_%j.err # change this!

set -ueo pipefail

# get conda
N_CORES=6
module load miniforge3
eval "$(conda shell.bash hook)"

# DOWNLOAD RAW READS #############################################################

# set filepath vars
SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/group_project"
DB_DIR="${SCR_DIR}/db"
DL_DIR="${PROJECT_DIR}/data/raw"
SRA_DIR="${SCR_DIR}/SRA"

# if SRA_DIR doens't exist, create it
[ -d "$SRA_DIR" ] || mkdir -p "$SRA_DIR"


# download the accession(s) listed in `./data/accessions.txt`
# only if they don't exist
for ACC in $(cat ./data/accessions.txt)
do

if [ ! -f "${SRA_DIR}/${ACC}/${ACC}.sra" ]; then
prefetch --output-directory "${SRA_DIR}" "$ACC"
fasterq-dump "${SRA_DIR}/${ACC}/${ACC}.sra" --outdir "$DL_DIR" --skip-technical --force --temp "${SCR_DIR}/tmp"
fi

done


# compress all downloaded fastq files (if they haven't been already)
if ls ${DL_DIR}/*.fastq >/dev/null 2>&1; then
gzip ${DL_DIR}/*.fastq
fi

# DOWNLOAD DATABASES #############################################################

# metaphlan is easiest to use via conda
# and metaphlan can install its own database to use
conda env list | grep -q '^metaphlan4-env' || mamba create -y -n metaphlan4-env -c bioconda -c conda-forge metaphlan

# look for the metaphlan database, only download if it does not exist already
if [ ! -f "${DB_DIR}/metaphlan/mpa_latest" ]; then
conda activate metaphlan4-env
# install the metaphlan database using N_CORES
# N_CORES is set in the pipeline.slurm script
metaphlan --install --db_dir "${DB_DIR}/metaphlan" --nproc $N_CORES
conda deactivate
fi


# prokka (also using conda, also installs its own database)
conda env list | grep -q '^prokka-env' || mamba create -y -n prokka-env -c conda-forge -c bioconda prokka
conda activate prokka-env
export PROKKA_DB=${DB_DIR}/prokka
prokka --setupdb --dbdir $PROKKA_DB
conda deactivate
```
## To run it, use the following

```
sbatch 01_download.sh
```

## After that script is complete, I moved on to do quality control with 02_qc.sh
## It will trim bases below quality 20 and discard reads shorter than 100 basepairs. It also ensures no reads with “N” bases are kept. All the clean reads are then put in ~/scr10/group_project/data/clean
## This script and all the following scripts were ran as slurm jobs. 

```
nano 02_qc.sh
```

## And here is the 02_qc.sh content

```
#!/bin/bash
#SBATCH --job-name=gp_Quality
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=USER@wm.edu               # change this!
#SBATCH -o /sciclone/home/USER/logs/gpQuality_%j.out # change this!
#SBATCH -e /sciclone/home/USER/logs/gpQuality_%j.err # change this!

set -ueo pipefail

SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/group_project"
DB_DIR="${SCR_DIR}/db"
DL_DIR="${PROJECT_DIR}/data/raw"
SRA_DIR="${SCR_DIR}/SRA"
QC_DIR="${PROJECT_DIR}/data/clean"

mkdir -p "$QC_DIR"

for fwd in ${DL_DIR}/*_1.fastq.gz;do rev=${fwd/_1.fastq.gz/_2.fastq.gz};outfwd=${fwd/$DL_DIR/$QC_DIR}; outrev=${rev/$DL_DIR/$QC_DIR}; outfwd=${outfwd/.fastq.gz/_qc.fastq.gz}; outrev=${outrev/.fastq.gz/_qc.fastq.gz};fastp -i $fwd -o $outfwd -I $rev -O $outrev -j /dev/null -h /dev/null -n 0 -l 100 -e 20;done
# all QC files will be in $QC_DIR and have *_qc.fastq.gz naming pattern
```

## With clean reads now in my ~/scr10/data/clean folder, I moved onto the assembly step of the pipeline. 
## Script 03_assemble_template.sh will handle this step. This is a script that will build scripts to run as a slurm job. It will make it so that assembly for each sample will run as its own slurm job. 
## In each resulting script, the quality control reads will undergo metagenome assembly with SPAdes. Each sample will go into its own assembly folder.

```
nano 03_assemble_template.sh
```

## Here is the contents of 03_assemble_template.sh

```
#!/bin/bash
#SBATCH --job-name=REPLACEME_gpAssembly
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=USER@wm.edu               # change this!
#SBATCH -o /sciclone/home/USER/logs/REPLACEME_%j.out # change this!
#SBATCH -e /sciclone/home/USER/logs/REPLACEME_%j.err # change this!

set -ueo pipefail

SCR_DIR="${HOME}/scr10" # change to main writeable scratch space if not on W&M HPC
PROJECT_DIR="${SCR_DIR}/group_project"
DB_DIR="${SCR_DIR}/db"
QC_DIR="${PROJECT_DIR}/data/clean"
SRA_DIR="${SCR_DIR}/SRA"
CONTIG_DIR="${PROJECT_DIR}/contigs"

mkdir -p $CONTIG_DIR

for fwd in ${QC_DIR}/*REPLACEME*1_qc.fastq.gz
do

# derive input and output variables 
rev=${fwd/_1_qc.fastq.gz/_2_qc.fastq.gz}
filename=$(basename $fwd)
samplename=$(echo ${filename%%_*})
outdir=$(echo ${CONTIG_DIR}/${samplename})

#run spades with mostly default options
spades.py -1 $fwd -2 $rev -o $outdir -t 20 --meta
done
```

## Rather than just running this script, I will replace the REPLACEMEs in the script with each accession number. I can just do this in the command line.

```
cd ..

for i in $(cat ./data/accessions.txt); do cat ./scripts/03_assemble_template.sh | sed "s/REPLACEME/${i}/g" >> ./scripts/${i}_assemble.slurm;done
```
## With 10 new slurm jobs now created, I can submit them all to slurm. 

```
for i in ./scripts/SRR*.slurm; do sbatch ${i}; done

cd scripts
```

## After all the assembly slurm jobs are done, I moved onto annotating the samples with 04_annotate_template.sh. This script annotates each assembled genome/metagenome using Prokka. The output of this script for each sample will go within its own annotations folder. I made another template script for this since just submitting 1 job that loops through all the samples took way too long and my job failed. 

```
nano 04_annotate_template.sh
```

## Here is the content of 04_annotate_template.sh.

```
#!/bin/bash
#SBATCH --job-name=REPLACEME_Annotate
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00 # each should only take ~30-60 minutes
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=USER@wm.edu               # change this!
#SBATCH -o /sciclone/home/USER/logs/REPLACEME_anno_%j.out # change this!
#SBATCH -e /sciclone/home/USER/logs/REPLACEME_anno_%j.err # change this!

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


for fwd in ${QC_DIR}/*REPLACEME*1_qc.fastq.gz
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
```
## Now I can use the template script to make annotate scripts for each sample and submit them.

```
cd ..

for i in $(cat ./data/accessions.txt); do cat ./scripts/04_annotate_template.sh | sed "s/REPLACEME/${i}/g" >> ./scripts/${i}_annotate.slurm;done

for i in ./scripts/*_annotate.slurm; do sbatch ${i}; done

cd scripts
```
## And now for the final step were we do coverage. This is the only script where I changed something in my pipeline that is different from the rest of my group. 
## I have a summary of what things each group member changed from our pipeline in output in GroupProject_Summary.csv 

## In the coverage script, 05_coverage.sh, I made a change to a bowtie2 parameter. I added the --very-fast parameter. I also changed it so that my output contained my intials RGA. They now end with *_RGA.with_cov.tsv. For example, SRR31654305_RGA.with_cov.tsv 

## This script will map clean reads to contigs, count reads per gene, calculate TPM per gene, and merge the coverage metrics with the annotation files.

```
nano 05_coverage.sh
```

## Here is the contents of 05_coverage.sh

```
#!/bin/bash
#SBATCH --job-name=gp_coverage
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1-00:00:00 
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=USER@wm.edu               # change this!
#SBATCH -o /sciclone/home/USER/logs/gpCoverage_%j.out # change this!
#SBATCH -e /sciclone/home/USER/logs/gpCoverage_%j.err # change this!

set -ueo pipefail

# filepath vars
SCR_DIR="${HOME}/scr10"
PROJECT_DIR="${SCR_DIR}/group_project"
QC_DIR="${PROJECT_DIR}/data/clean"
CONTIG_DIR="${PROJECT_DIR}/contigs"
ANNOT_DIR="${PROJECT_DIR}/annotations"
MAP_DIR="${PROJECT_DIR}/mappings"
COV_DIR="${PROJECT_DIR}/coverm"

mkdir -p "${MAP_DIR}" "${COV_DIR}"

# load conda
module load miniforge3
eval "$(conda shell.bash hook)"

# check if coverm-env exists, if not, create it
if ! conda env list | awk '{print $1}' | grep -qx "subread-env"; then     echo "[setup] creating subread-env with mamba";     mamba create -y -n subread-env -c bioconda -c conda-forge subread bowtie2 samtools; fi

# activate env
conda activate subread-env

# main loop
for fwd in ${QC_DIR}/*1_qc.fastq.gz
do
    rev=${fwd/_1_qc.fastq.gz/_2_qc.fastq.gz}
    filename=$(basename "$fwd")
    samplename=$(echo "${filename%%_*}")
    contigs="${CONTIG_DIR}/${samplename}/contigs.fasta"
    contigs_safe=${contigs/.fasta/.safe.fasta}
    gff="${ANNOT_DIR}/${samplename}/${samplename}.gff"
    bam="${MAP_DIR}/${samplename}.bam"
    cov_out="${COV_DIR}/${samplename}_gene_tpm.tsv"

    echo "[sample] ${samplename}"

    # index contigs if needed
        echo "  [index] bowtie2-build ${contigs_safe}"
        bowtie2-build "${contigs_safe}" "${contigs_safe}"

    # map reads to contigs
        echo "  [map] mapping reads"
        bowtie2 --very-fast -x "${contigs_safe}" -1 "$fwd" -2 "$rev" -p 8 \
          2> "${MAP_DIR}/${samplename}.bowtie2.log" \
        | samtools view -b - \
        | samtools sort -@ 8 -o "${bam}"
        samtools index "${bam}"

 # run featureCounts per gene (CDS), then compute TPM
    counts="${COV_DIR}/${samplename}_gene_counts.txt"
    tpm_out="${COV_DIR}/${samplename}_gene_tpm.tsv"

    echo "  [featureCounts] counting reads per CDS (locus_tag)"
    featureCounts \
      -a "${gff}" \
      -t CDS \
      -g locus_tag \
      -p -B -C \
      -T 20 \
      -o "${counts}" \
      "${bam}"

    echo "  [TPM] calculating TPM"
    awk 'BEGIN{OFS="\t"}
         NR<=2 {next}                           # skip header lines
         {
           id=$1; len=$6; cnt=$(NF);           # Geneid, Length, sample count is last column
           if (len>0) {
             rpk = cnt/(len/1000);
             RPK[id]=rpk; LEN[id]=len; CNT[id]=cnt; ORDER[++n]=id; SUM+=rpk;
           }
         }
         END{
           print "gene_id","length","counts","TPM";
           for (i=1;i<=n;i++){
             id=ORDER[i];
             tpm = (SUM>0 ? (RPK[id]/SUM)*1e6 : 0);
             printf "%s\t%d\t%d\t%.6f\n", id, LEN[id], CNT[id], tpm;
           }
         }' "${counts}" > "${tpm_out}"

    echo "  [done] ${tpm_out}"

    echo "  [done] ${cov_out}"

# join the coverage estimation info back to the annotation file

ann="${ANNOT_DIR}/${samplename}/${samplename}.tsv"
joined="${ANNOT_DIR}/${samplename}/${samplename}_RGA.with_cov.tsv" #CHANGE IN TO YOUR INITIAL

echo "  [join] adding coverage columns to annotation TSV"
awk -v FS='\t' -v OFS='\t' -v keycol='locus_tag' '
  # Read TPM table: gene_id  length  counts  TPM
  NR==FNR {
    if (FNR==1) next
    id=$1; LEN[id]=$2; CNT[id]=$3; TPM[id]=$4
    next
  }
  # On the annotation header, find which column is locus_tag
  FNR==1 {
    for (i=1;i<=NF;i++) if ($i==keycol) K=i
    if (!K) { print "ERROR: no \"" keycol "\" column in annotation header" > "/dev/stderr"; exit 1 }
    print $0, "cov_length_bp", "cov_counts", "cov_TPM"
    next
  }
  # Append coverage fields if we have them
  {
    id=$K
    print $0, (id in LEN? LEN[id]:"NA"), (id in CNT? CNT[id]:"0"), (id in TPM? TPM[id]:"0")
  }
' "${tpm_out}" "${ann}" > "${joined}"

echo "  [done] ${joined}"

done
```

## Since the output files I want are still in scratch space (scr10), I navigated there to copy the files I want and move them to my groupProject/output directory 

```
cd
cd ~/scr10/group_project
mkdir -p output
cd annotations
cp */*_RGA.with_cov.tsv ../output
cp output/* ~/BIOCOMPUTING/groupProject/output
cd 
cd ~/BIOCOMPUTING/groupProject/
```
## So now all of my output files are all in one place and ready to push to github!!!
## In my output folder, I have all my *_RGA.with_cov.tsv, a summary table for the changes my group members made called GroupProject_Summary.csv, and a summary table for information about each accession number we used called GroupProject_Summary.csv. I am also going to copy my README there so it is easier to find. 

## To clean up my scripts folder since I had 2 scripts that made scripts, I moved the resulting scripts into an annotation_slurm folder or an assemble_slurm folder. 

```
cd scripts
mkdir -p annotation_slurm assemble_slurm
mv *_annotate.slurm annotation_slurm
mv *_assemble.slurm assemble_slurm 
```

