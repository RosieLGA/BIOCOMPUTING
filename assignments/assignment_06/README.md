### Rosie George-Ambrocio
### October 13, 2025
### Assignment 06

## Start off by signing into the hpc. Login into the bora server via ssh

```
ssh yourID@bora.sciclone.wm.edu
cd BIOCOMPUTING
ls
```

## My BIOCOMPUTING repository currently has the following highest order subfolders and files: assignments/ groupProject/ lessons/ practice/ programs/ quizzes/ README.md
## assignments/ has dedicated subfolders for assignment_0{1..8}. lessons/ has dedicated subfolders for lesson_0{1..8}. practice/ has a subfolder for self-created practice (./personal/) and a subfolder for assigned practice (./provided/). quizzes/ has dedicated subfolders for quiz_0{1..8}.


### **Task 1** : Setup assignment_06 directory
## Set my directory to assignment_06,

```
cd ./assignments/assignment_06
```

## Make directories for assemblies, data, and scripts

```
mkdir -p assemblies/assembly_{conda,local,module} data scripts
```

## And make a README.md for documentation

```
touch README.md
```

### **Task 2** : Download raw ONT data
## Since I am making a script called 01_download_data.sh, I am going to use nano to write within the script

```
nano ./scripts/01_download_data.sh
```

## Here is what is inside that script: 

```
#!/bin/bash
set -ueo pipefail

# Download the small genomic dataset
wget https://zenodo.org/records/15730819/files/SRR33939694.fastq.gz

# make data directory
mkdir -p ./data

# and move the data to the ./data folder
mv *fastq.gz ./data
```

## That is the end of script content. Now to make it executable

```
chmod +x ./scripts/01_download_data.sh
```

## and lets see what happens when we run it

```
./scripts/01_download_data.sh
```

## Success! I checked the data folder contents and the data was there

### **Task 3** : Get Flye v2.9.6 (local build)
## Time to make another script. This one is named ./scripts/02_flye_2.9.6_manual_build.sh
## This script will get Flye v2.9.6 for us and place it in our ~/programs/ directory 

```
nano ./02_scripts/flye_2.9.6_manual_build.sh
```

## Here is what is inside that script: 

```
#!/bin/bash
set -ueo pipefail

# The following is code provided on https://github.com/mikolmogorov/Flye/blob/flye/docs/INSTALL.md#local-building-without-installation
git clone --branch 2.9.6 https://github.com/fenderglass/Flye
cd Flye
make

# Checkpoint
echo 'download done'
echo "checking flye version"
./bin/flye --version

# Since this needs to go to ~/programs/ directory, we will move Flye there
cd .. # This moves us back into the assignment_06 directory instead of being within the Flye folder
mv Flye ~/programs/


```

## That is the end of script content. Now to make it executable

```
chmod +x ./scripts/02_flye_2.9.6_manual_build.sh
```

## and lets see what happens when we run it

```
./scripts/02_flye_2.9.6_manual_build.sh
```

# I need to add the location of Flye to my $PATH so that I can call it from anywhere

```
echo 'export PATH=$PATH:/sciclone/home/rlgeorgeambroc/programs/Flye/bin' >> ~/.bashrc
exec bash
```
### **Task 3** : Get Flye v2.9.6 (conda build)
## Time to build a script named ./scripts/02_flye_2.9.6_conda_install.sh

```
nano ./scripts/02_flye_2.9.6_conda_install.sh
```

## Here is what is inside that script: 

```
#!/bin/bash
set -ueo pipefail

# load miniforge3
module load miniforge3

# source conda
source /sciclone/apps/miniforge3-24.9.2-0/etc/profile.d/conda.sh

# build a conda environment for Flye v2.9.6 called "flye-env"
mamba create -y -n flye-env -c bioconda -c conda-forge flye=2.9.6
conda activate flye-env

# test it out with flye -v
echo "flye -v"
flye -v

# Document the environment by exporting a yml file of all the dependencies and versions
conda env export --no-builds > flye-env.yml

# Deactivate the environment
conda deactivate

```

## That is the end of script content. Now to make it executable

```
chmod +x ./scripts/02_flye_2.9.6_conda_install.sh
```

## and lets see what happens when we run it

```
./scripts/02_flye_2.9.6_conda_install.sh
```

## My script informed me that I have the 2.9.6-b1802 version of flye

# Deactivate the environment. I originally had this as part of the 02_flye_2.9.6_conda_install.sh. However, I believe I need to use this script within my script for Task 6A. 

```
conda deactivate
```

### **Task 5** : Decipher how to use Flye
## I will start by looking through the help documentation

```
Flye --help
```

## Here is the flye command I created. It uses the raw ONT reads, estimates the genome size to be 500k, uses 6 threads on the login node, and saves the assembly results in a designated directory

```
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/task5_flycommand
```

### **Task 6** : Run Flye, 3 ways

## 6A. Write a script to run Flye using conda
# The name of this script will be ./scripts/03_run_flye_conda.sh

```
nano ./scripts/03_run_flye_conda.sh

```

# Here is the script: 

```
#!/bin/bash
set -ueo pipefail

# load conda and the flye-env
./scripts/02_flye_2.9.6_conda_install.sh

# create the output directory
mkdir -p ./assemblies/assembly_conda

# use flye 
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/assembly_conda

# navigate to the output directory
cd ./assemblies/assembly_conda

# rename the 'assembly.fasta` to `conda_assembly.fasta` and flye.log to conda_flye.log

mv assembly.fasta conda_assembly.fasta
mv flye.log conda_flye.log

# remove the bloat files
# this removes everything except the files we want to keep

rm -r 00-assembly 10-consensus 20-repeat 30-contigger 40-polishing assembly_graph.gfa assembly_graph.gv assembly_info.txt params.json

# deactivate the flye-env
conda deactivate
```
# Make the script executable and run it!

```
chmod +x ./scripts/03_run_flye_conda.sh
./scripts/03_run_flye_conda.sh
```

# Everything in ./assemblies/assembly_conda looks good! One problem is that I got an error that says "CondaError: Run 'conda init' before 'conda deactivate'" which is something I do not want to run. By modifying the end of my script with 'conda deactivate || true' instead of just 'conda deactivate', online sources say it allows the script to continue even if deactivate fails. I still get the same error ... but this feels safer  

#Here is the updated script: 

```
#!/bin/bash
set -ueo pipefail

# load conda and the flye-env
./scripts/02_flye_2.9.6_conda_install.sh

# create the output directory
mkdir -p ./assemblies/assembly_conda

# use flye 
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/assembly_conda

# navigate to the output directory
cd ./assemblies/assembly_conda

# rename the 'assembly.fasta` to `conda_assembly.fasta` and flye.log to conda_flye.log

mv assembly.fasta conda_assembly.fasta
mv flye.log conda_flye.log

# remove the bloat files
# this removes everything except the files we want to keep

rm -r 00-assembly 10-consensus 20-repeat 30-contigger 40-polishing assembly_graph.gfa assembly_graph.gv assembly_info.txt params.json

# source conda
source /sciclone/apps/miniforge3-24.9.2-0/etc/profile.d/conda.sh

# deactivate the flye-env
conda deactivate
```

# and lets run it again 

```
./scripts/03_run_flye_conda.sh
```

## 6B. Same as 6A, but using the module environment
# The name of this script is 03_run_flye_module.sh

```
nano ./scripts/03_run_flye_module.sh

```

# Here is the script contents: 

```
#!/bin/bash
set -ueo pipefail

# load the flye module
module avail 
module load Flye/gcc-11.4.1/2.9.6

# create the output directory
mkdir -p ./assemblies/assembly_module

# use flye 
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/assembly_module

# navigate to the output directory
cd ./assemblies/assembly_module

# rename the 'assembly.fasta` to `module_assembly.fasta` and flye.log to module_flye.log

mv assembly.fasta module_assembly.fasta
mv flye.log module_flye.log

# remove the bloat files
# this removes everything except the files we want to keep

rm -r 00-assembly 10-consensus 20-repeat 30-contigger 40-polishing assembly_graph.gfa assembly_graph.gv assembly_info.txt params.json

```

# Make the script executable and run it!

```
chmod +x ./scripts/03_run_flye_module.sh
./scripts/03_run_flye_module.sh
```

# Looks like it is working fine

## 6C. Same as 6A, but pointing flye to your local build
# The name of this script is 03_run_flye_local.sh

```
nano ./scripts/03_run_flye_local.sh

```

# Here is the script contents: 

```
#!/bin/bash
set -ueo pipefail

# run ./scripts/02_flye_2.9.6_manual_build.sh
./scripts/02_flye_2.9.6_manual_build.sh

# make sure Flye is added to your path
export PATH="$HOME/programs/Flye/bin:$PATH"

# create the output directory
mkdir -p ./assemblies/assembly_local

# use flye 
flye --nano-raw ./data/SRR33939694.fastq.gz \
     --genome-size 500k \
     --threads 6 \
     --out-dir ./assemblies/assembly_local

# navigate to the output directory
cd ./assemblies/assembly_local

# Check that assembly.fasta exists and is non-empty. I kept getting an error saying that assembly.fasta did not exist but it did when I checked my folder. The script wont move on until the file is written

if [[ ! -s assembly.fasta ]]; then
    echo "ERROR: assembly.fasta not found or empty!"
    exit 1
fi


# rename the 'assembly.fasta` to `local_assembly.fasta` and flye.log to local_flye.log

mv assembly.fasta local_assembly.fasta
mv flye.log local_flye.log

# remove the bloat files
# this removes everything except the files we want to keep

rm -r 00-assembly 10-consensus 20-repeat 30-contigger 40-polishing assembly_graph.gfa assembly_graph.gv assembly_info.txt params.json

```

# Make the script executable and run it!

```
chmod +x ./scripts/03_run_flye_local.sh
./scripts/03_run_flye_local.sh
```

# Still looking good

### **Task 7** :Compare the results in the log files
## to inspect the local log file

```
echo "Last 10 lines of local_flye.log"
tail -n 10 ./assemblies/assembly_local/local_flye.log
```

## to inspect the conda log file

```
echo "Last 10 lines of conda_flye.log"
tail -n 10 ./assemblies/assembly_conda/conda_flye.log
```

## to inspect the module log file

```
echo "Last 10 lines of module_flye.log"
tail -n 10 ./assemblies/assembly_module/module_flye.log
```

## I actually did not see any difference in the last 10 lines so hopefully I did not make a mistake and was supposed to see differences

### **Task 8** :Build a `pipeline.sh` script

```
nano pipeline.sh
```

## Here is the script!

```
#!/bin/bash
set -ueo pipefail

# the data download
./scripts/01_download_data.sh
echo 'Data Downloaded'

# run flye with local
./scripts/03_run_flye_local.sh
echo 'Ran Flye on local'

# run flye with conda
./scripts/03_run_flye_conda.sh
echo 'Ran Flye on Conda'

# run flye with module
./scripts/03_run_flye_module.sh
echo 'Ran Flye on Module'



# Look at the last 10 lines of local_flye.log
echo "Last 10 lines of local_flye.log"
tail -n 10 ./assemblies/assembly_local/local_flye.log
echo

# Look at the last 10 lines of conda_flye.log
echo "Last 10 lines of conda_flye.log"
tail -n 10 ./assemblies/assembly_conda/conda_flye.log
echo

# Look at the last 10 lines of module_flye.log
echo "Last 10 lines of module_flye.log"
tail -n 10 ./assemblies/assembly_module/module_flye.log
echo
```

# Make the script executable and run it!

```
chmod +x pipeline.sh
./pipeline.sh
```

### **Task 9** : Delete everything except scripts
## IT WORKS!!!

### **Task 10** : Document in README.md
## Done and Done

## Reflection
# I would say that my major challenge was formatting my README.md and scripts in a way that anyone could run and use them without getting into any issues due to file paths or missing directories. I wanted to focus on making this assignment highly reproducible, but at times I ended up confusing myself. Another challenge was keeping my scripts organized and being able to recall what each does. Good thing the script names were very informative!  
# I definitely learned a lot during this assignment. I got log file outputs where the last 10 lines were matching between environments. I think this means that ensuring I know what version of I program I install/use and how to craft each environment type is important in making sure that my biocomputing findings are valid. I also learned that using 6 login nodes can be a very slow process. 
# I preferred using the module. I did not like using conda mostly because I thought it was the most complicated method. I especially was frustrated with it when something went wrong and the advice online was to use conda init, the very thing I wanted to avoid. For the next assignment, I will likely use module. The local/manual method was okay too, but I think it was easier to make my workflow reproducible using module since local meant storing a program in my programs folder which is outside of my assignment folder. 

### **Task 11** : Push to GitHUb
## I was sure to not push the fastq file to github
