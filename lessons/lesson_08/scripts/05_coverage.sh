#!/bin/bash
#SBATCH --job-name=MG_Coverage
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=600 # asking for ten hours since each should only take ~30-60 minutes
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=rlgeorgeambroc@wm.edu               # change this!
#SBATCH -o /sciclone/home/rlgeorgeambroc/logs/assembly_%j.out # change this!
#SBATCH -e /sciclone/home/rlgeorgeambroc/logs/assembly_%j.err # change this!


# filepath vars
SCR_DIR="${HOME}/scr10"
PROJECT_DIR="${SCR_DIR}/mg_assembly_08"
DL_DIR="${PROJECT_DIR}/data/raw"
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
for fwd in ${DL_DIR}/*1_qc.fastq.gz
do
    rev=${fwd/_1_qc.fastq.gz/_2_qc.fastq.gz}
    filename=$(basename "$fwd")
    samplename=$(echo "${filename%%_*}")
    contigs="${CONTIG_DIR}/${samplename}/contigs.fasta"
    gff="${ANNOT_DIR}/${samplename}/${samplename}.gff"
    bam="${MAP_DIR}/${samplename}.bam"
    cov_out="${COV_DIR}/${samplename}_gene_tpm.tsv"

    echo "[sample] ${samplename}"

    # index contigs if needed
    if [[ ! -f "${contigs}.1.bt2" ]]; then
        echo "  [index] bowtie2-build ${contigs}"
        bowtie2-build "${contigs}" "${contigs}"
    fi

    # map reads to contigs
    if [[ ! -s "${bam}" ]]; then
        echo "  [map] mapping reads"
        bowtie2 -x "${contigs}" -1 "$fwd" -2 "$rev" -p 8 \
          2> "${MAP_DIR}/${samplename}.bowtie2.log" \
        | samtools view -b - \
        | samtools sort -@ 8 -o "${bam}"
        samtools index "${bam}"
    fi

 # run featureCounts per gene (CDS), then compute TPM
    counts="${COV_DIR}/${samplename}_gene_counts.txt"
    tpm_out="${COV_DIR}/${samplename}_gene_tpm.tsv"

    echo "  [featureCounts] counting reads per CDS (locus_tag)"
    featureCounts \
      -a "${gff}" \
      -t CDS \
      -g locus_tag \
      -p -B -C \
      -T 8 \
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
joined="${ANNOT_DIR}/${samplename}/${samplename}.with_cov.tsv"

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
