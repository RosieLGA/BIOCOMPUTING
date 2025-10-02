# Rosie George-Ambrocio
# October 1, 2025
# Assignment 04

## Start off by signing into the hpc. Login into the bora server via ssh

```
ssh yourID@bora.sciclone.wm.edu
cd BIOCOMPUTING
ls
```

## My BIOCOMPUTING repository currently has the following highest order subfolders and files: assignments/ groupProject/ lessons/ practice/ programs/ quizzes/ README.md
## assignments/ has dedicated subfolders for assignment_0{1..8}. lessons/ has dedicated subfolders for lesson_0{1..8}. practice/ has a subfolder for self-created practice (./personal/) and a subfolder for assigned practice (./provided/). quizzes/ has dedicated subfolders for quiz_0{1..8}.


# **Task 1** : Setup assignment_05 directory
## Set my directory to assignment_05,

```
cd ./assignments/assignment_05
```

## Make directories for data/raw, data/trimmed, log, and scripts

```
mkdir -p data/{raw,trimmed} log scripts
```

## And make a README.md for documentation

```
touch README.md
```

# **Task 2** : Script to download and prepare fastq data

## Move into ./scripts and create 01_download_data.sh using nano

```
cd ./scripts 
nano 01_download_data.sh
```

## The following is what I put in my script: 

```
#!/bin/bash
set -ueo pipefail

# I am setting my directory to where I will house my raw data
MAIN_DIR=${HOME}/BIOCOMPUTING/assignments/assignment_05/data/raw
cd ${MAIN_DIR}

# Downland the data from the provided link
wget https://gzahn.github.io/data/fastq_examples.tar

# Extract the contents
tar -xf fastq_examples.tar

# And clean up the `fastq_examples.tar` file
rm fastq_examples.tar
```

## Now I need to make the script executable using chmod

```
chmod +x 01_download_data.sh
```

# **Task 3**: Install and explore the fastp tool

## Using cd is a fast way to get me back to root. From there, I can set my directory to ./programs

```
cd 
cd ./ programs
```

## The directions from the provided link told me to run the following: 

```
wget http://opengene.org/fastp/fastp
chmod a+x ./fastp
```

## And it worked! Looking at the help menu for the tool showed me to use -v to find what version of fastp I now have. 

```
fastp --help
fastp -v
```

## I have fastp 1.0.1

## fastp is in my programs folder, and this is already on my .bashrc. This is what I have on my .bashrc

```
export PATH=$PATH:/sciclone/home/rlgeorgeambroc/programs
```

## Back in the programs directory, I looked over what options come with fastp until I felt comfortable enough to continue with the assignment. I also asked ChatGPT to tell me about what I can accomplish using fastp

```
fastp --help
```

# **Task 4**: Script to run fastp

## Since I am currently in programs, I went back a level then navigated into  ./BIOCOMPUTING/assignments/assignment_05/scripts so that I can create my 02_run_fastp.sh script

```
cd 
cd ./BIOCOMPUTING/assignments/assignment_05/scripts
nano 02_run_fastp.sh 
```

## Since I believe all the html files need to go to ./log/, I am going to create a parameter for Sample and the html output. I am not certain that this is correct since the parameter table says "--html /dev/null" on one side and "path/name of HTML report 
(goes to ./log/)" on the other. For the SAMPLE names, I am essentially chopping off everything that follows the _R1_ match.

## I also want to note that when I first ran pipeline.sh with an early version of 02_run_fastp.sh, the trimmed data was generated but the htmls in ./log did not. After messing with both scripts many times, I finally asked ChatGPT what was wrong with my script(s). It turned out that I was extracting sample names with their full relative path instead of just the file name. To fix this, I just had to use another parameter expansion to trim the file path off. Meaning, I chopped everything that follows the _R1_ match and everything that came before everything before and including the last slash to remove the file path. 

## In my 02_run_fastp.sh, I have written the following

```
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
```

## Now I need to make it executable. 

```
chmod +x 02_run_fastp.sh
```

## I did try out the script on a random *_R1_* data file and I saw a sample name echoed to my screen and a correctly named html in ./log. I also see information about read 1 and read 2 before and after filtering. 

# **Task 5**: 'pipeline.sh' script

## Now I am going back to my assignment_05 directory to create pipeline.sh

```
cd ..
nano pipeline.sh
```

## Here is what is inside that script: 

```
#!/bin/bash
set -ueo pipefail

# run ./scripts/01_download_data.sh to download data
./scripts/01_download_data.sh

# run a for-loop for all the newly downloaded data using ./scripts/02_run_fastp.sh

for i in ./data/raw/*_R1_*.fastq.gz
do
./scripts/02_run_fastp.sh "${i}"
done

# move the trimmed files to a different folder
mv ./data/raw/*trimmed* ./data/trimmed
```

## That is the end of script content. Now to make it executable

```
chmod +x pipeline.sh
```

## And lets see what happens when we run it

```
./pipeline.sh
```

## Success!


# **Task 6**: delete all data files and start over

## To remove the data files (while still in the assignment_05 directory), I can use rm and list the file paths. Using * removes everything in the folder
```
rm data/raw/* data/trimmed/* log/*
```

## Time to re-run pipeline.sh

```
./pipeline.sh
``` 



## Success!!!

# **Task 7**: Document Everything in README.md

## I have been doing this as I work through the assignment (like always)

## **Reflection**:

### I did have a challenge when trying to get my html files to appear. It worked at first when I ran 02_run_fastp.sh outside of pipeline.sh but not when I ran it within pipeline.sh. It turned out my problem was that the HTML report paths included the full relative path from ./data/raw/  instead of just the sample name. I used ChatGTP to spot my problem. I can say that this experience made me a whole lot more aware of file paths and made me a lot more grateful for the table of parameter expansion methods in Lesson 5. I needed to remove a match from the front and from the end to derive the appropriate variable name. 

### I learned that tools like fastp are extremely helpful, especially if you look over the --help items. I was a bit intimidated when I read over the instructions to Task 4, but I was shocked at how simple setting the fastp parameters actually was. I also learned it takes a lot of patience when building scripts that run other scripts. I was feeling frustrated when my script 01_download_data.sh and script 02_run_fastp.sh worked well on their own but not when I ran the pipeline.sh. It failed once it tried to run 02_run_fastp.sh in a for-loop. It turned out it was a simple fix if I had just recalled how file paths worked. 

### This assignment also helped me understand why we split this up into two scripts and then called each one with an overall "pipeline." When I encountered my error with the html files disappearing, I knew the problem was not in script 1 since checkpoint I put there (a simple echo of a variable to standard output) appeared properly. I was able to detect that my problem was either in script 2 or in the for-loop I made to run script 2. If I hadn't had done this, I would have been combing through a very long script to see where the issue was. Being able to detect a coding issue more quickly is a major pro. I would say that a possible con is that you would have to cat multiple scripts to your screen to understand what happened in your overline pipeline. This can be a lot if I have a lot of scripts in a single pipeline script. 
