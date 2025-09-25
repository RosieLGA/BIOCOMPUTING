# Rosie George-Ambrocio
# September 24, 2025
# Assignment 04

# Task 1 : Make a programs directory
## I already have a directory called "programs" in my $HOME

bora

cd programs

# Task 2 : Download and unpack the gh "tarball" file

wget https://github.com/cli/cli/releases/download/v2.74.2/gh_2.74.2_linux_amd64.tar.gz

tar -xzvf gh_2.74.2_linux_amd64.tar.gz

rm -r gh_2.74.2_linux_amd64.tar.gz

# Task 3 : Build a bash script from task 2

nano install_gh.sh

## inside the window that open from nano: copy and paste the following exactly (up until "so that we can run..")

#!/bin/bash


wget https://github.com/cli/cli/releases/download/v2.74.2/gh_2.74.2_linux_amd64.tar.gz

tar -xzvf gh_2.74.2_linux_amd64.tar.gz

rm -r gh_2.74.2_linux_amd64.tar.gz

## so that we can run the script, we need to adjust the permissions 

chmod +x install_gh.sh

# Task 4 : Run your install_gh.sh script
## to do this, I will delete the files I just downloaded to make sure the script works properly

rm -r gh_2.74.2_linux_amd64

exec bash

install_gh.h

# Task 5 : Add the location of the gh binary to your $PATH
## I am still within /programs, but I will move within /programs/gh_2.74.2_linux_amd64/bin so that I can print the directory and add it to my PATH

cd gh_2.74.2_linux_amd64/bin

pwd

## I copied the output and pasted it after export PATH=$PATH:

export PATH=$PATH:/sciclone/home/rlgeorgeambroc/programs/gh_2.74.2_linux_amd64/bin

## And I can check if this worked 

echo $PATH


# Task 6 : Run gh auth login to setup your GitHub username and password
## In the HPC

gh auth login

## And I will answer the questions it gives me like how I was instructed to in assignment_00, but I will login in with a token instead of a web browser

## now I am logged in!

cd ~/programs

# Task 7 : Create another installation script (for seqtk)
## For this task, I followed the instructions on the README.md from the provided GitHub repo
## I will name the script install_seqtk.sh

nano install_seqtk.sh

## inside the window that open from nano: copy and paste the following exactly (up until "so that we can run.."). 

#!/bin/bash

git clone https://github.com/lh3/seqtk.git; cd seqtk; make

echo "export PATH=$PATH:/sciclone/home/rlgeorgeambroc/programs/seqtk" >> ~/.bashrc

## so that we can run the script, we need to adjust the permissions 

chmod +x install_seqtk.sh

exec bash


# Task 8 : Figure out seqkt

exec bash

cd ..

cd BIOCOMPUTING/assignments/assignment_03/data

## now I can try out seqtk on a file from a previous assignment. The README from GitHub and typing seqtk in my terminal is very helpful in seeing what I can do. Here are a few things I tried

seqtk seq -r GCF_000001735.4_TAIR10.1_genomic.fna  > reverse_complement.fna

seqtk size GCF_000001735.4_TAIR10.1_genomic.fna

seqtk cutN GCF_000001735.4_TAIR10.1_genomic.fna > cutN.fna

# Task 9 : Write a `summarize_fasta.sh` script

cd ../..

cd assignment_04

nano summarize_fasta.sh

## here is what I have written in my script: 

#!/bin/bash

# accepts the name of a fasta file as a positional argument and stores that filename in a variable

fasta_file=${1}

# calculate and stores total number of sequences and nucleotides

total_seq_nuc=$(seqtk size $fasta_file)

total_seq=$(echo "$total_seq_nuc" |cut -f1)

total_nuc=$(echo "$total_seq_nuc" |cut -f2)

# A table of sequence names and lengths (all seqs in file)

table=$(seqtk comp $fasta_file | cut -f1,2)

# output report

echo "Fasta Summary" 

echo "File: $fasta_file"

echo "Total Number of Sequences: $total_seq"

echo "Total Number of Nucleotides: $total_nuc"

echo "$table"

## That is the end of the script. I need to change the permissions 

chmod +x summarize_fasta.sh


# Task 10 : 
## I need to make a folder for data within /assignment_04
## I will also re-use the fasta file I already have, so I need to 

mkdir data

cd .. 

cd assignment_03/data

cp GCF_000001735.4_TAIR10.1_genomic.fna ~/BIOCOMPUTING/assignments/assignment_04/data

cd ../..

cd assignment_04/data

cp GCF_000001735.4_TAIR10.1_genomic.fna GCF_000001735.4_TAIR10.1_genomic_copy.fna

cp GCF_000001735.4_TAIR10.1_genomic.fna GCF_000001735.4_TAIR10.1_genomic_copyagain.fna

## I will also cp summarize_fasta.sh into my programs directory

cd ..

cp summarize_fasta.sh ~/programs

cd data

## and here is the forloop

for i in *.fna; do summarize_fasta.sh $i; done


# Task 11

## I have writing in an text-editor as I go! 

## Reflection

### It was challenging to try to find some fasta files on GenBank to use. I mostly found fasta files with a single sequence, and that did not seem like a good way to try out my script. It was also challenging to use seqtk at first, but I ended up learning a lot! seqtk comp and seqtk size was especially helpful in summarizing my files without having to do things like grep or paste to make a table. From just typing seqtk in my command line and hitting entering, I learned that seqtk has a command to rename sequence names and some to cut sequences. I think this foreshadows us possibly putting a raw data and clean data folder to good use later. $PATH is an environmental variable that I overwrite with an old version of itself plus a new file path that I add to it. $PATH is a way to tell my shell where to look for programs or scripts I am asking it to use. When I add to my $PATH, I am giving more places to look. This way, I can use programs in different directories without need to have that program in the directory. Instead, I can have my programs in /programs and $PATH will tell shell to look for it there so that I can execute the program in other places outside of /programs. However, I need to add the new path command to my ~/.bashrc file or I will have to re-inform my shell where to look every time I start my shell terminal.



