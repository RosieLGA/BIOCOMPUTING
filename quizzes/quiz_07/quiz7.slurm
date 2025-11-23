#!/bin/bash
#SBATCH --job-name=quiz7
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0-00:01:00
#SBATCH --mem=1G
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=rlgeorgeambroc@wm.edu               # change this!
#SBATCH -o /sciclone/home/rlgeorgeambroc/logs/quiz7_%j.out # change this!
#SBATCH -e /sciclone/home/rlgeorgeambroc/logs/quiz7_%j.err # change this!


echo "Hello world!"
