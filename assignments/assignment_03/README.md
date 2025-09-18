# Rosie George-Ambrocio
# September 17, 2025
# Assignment 03

## Start off by signing into the hpc. Login into the bora server via ssh

ssh yourID@bora.sciclone.wm.edu

## From previous assignments, I have already cloned my BIOCOMPUTING repository straight from GitHub. Currently, my local computer's GitHub repository reflects my HPC BIOCOMPUTING directory. I double-checked this by looking at both my local BIOCOMPUTING and the HPC BIOCOMPUTING in FileZilla. In the HPC, I will set BIOCOMPUTING as my directory and look around. 

cd BIOCOMPUTING

ls

## My BIOCOMPUTING repository currently has the following highest order subfolders and files: assignments/ groupProject/ lessons/ practice/ quizzes/ README.md
## assignments/ has dedicated subfolders for assignment_0{1..8}. lessons/ has dedicated subfolders for lesson_0{1..8}. practice/ has a subfolder for self-created practice (./personal/) and a subfolder for assigned practice (./provided/). quizzes/ has dedicated subfolders for quiz_0{1..8}.

# Task 1

## If you do not have a folder for assignments, run the following code

mkdir -p assignments/assignment_0{1..8}

## Now lets make add somethings to the assignment/assignment_03 folder

cd assignments/assignment_03

touch README.md

mkdir data 

ls


# Task 2

## Download a provided file from a url into assignment_03/data directory

cd data

wget https://gzahn.github.io/data/GCF_000001735.4_TAIR10.1_genomic.fna.gz

## and uncompress it using gunzip

gunzip GCF_000001735.4_TAIR10.1_genomic.fna.gz

## take a look at this file to see what we have to work with

nano GCF_000001735.4_TAIR10.1_genomic.fna

## from this I see 7 sequences for A. thaliana. Some are partial sequences, some are whole genomes. Some are for chromosomes, and some are for chloroplasts or mitochondria.

# Task 3
### Since this task involves developing and running a series of commands to answer questions about the file we just obtained, I will split the commands up by their associated question number to make things more organized and less confusing. 

## Q1: How many sequences are in the FASTA file? 
### This command looks for the pattern ">" within the file and counts the number of times ">" appears. 

grep -c ">" GCF_000001735.4_TAIR10.1_genomic.fna

## Q2: What is the total number of nucleotides (not including header lines or newlines)? 
### I am looking for a pattern where a line does NOT start with ">" in my file. From those lines, I want to remove any newline characters. With what I have left, I want to count the number of characters since the remaining characters should be just my nucleotides. 

grep -v "^>" GCF_000001735.4_TAIR10.1_genomic.fna | tr -d '\n' | wc -c 

## Q3: How many total lines are in the file? 
### wc is means word count, and adding -l afterwards makes it count the number of lines. 

wc -l GCF_000001735.4_TAIR10.1_genomic.fna

## Q4: How many header lines contain the word "mitochondrion"? 
### I am looking for a pattern where I looking for lines starting with ">", and mitochondrion appears somewhere in the line. I want to end up with the number of lines that fit this criteria. 

grep "^>" GCF_000001735.4_TAIR10.1_genomic.fna | grep "mitochondrion" |wc -l

## Q5: How many header lines contain the word "chromosome"? 
### I can try the same approach as above. 

grep "^>" GCF_000001735.4_TAIR10.1_genomic.fna | grep "chromosome" |wc -l


## Q6: How many nucleotides are in each of the first 3 chromosome sequences? 
### This is tougher since I need to find the pattern of headers with the word "chromosome" and also need the their associated sequences. After using grep --help, I found that using grep -A can give me lines after the lines with the specified pattern I asked for it to look for. 

### chromosome 1
grep "chromosome" -A 1 GCF_000001735.4_TAIR10.1_genomic.fna | head -n 6 | grep -v "^>" | head -n 1 | wc -c

### chromosome 2
grep "chromosome" -A 1 GCF_000001735.4_TAIR10.1_genomic.fna | head -n 6 | grep -v "^>" | head -n 2 | tail -n 1 | wc -c

### chromosome 3
grep "chromosome" -A 1 GCF_000001735.4_TAIR10.1_genomic.fna | head -n 6 | grep -v "^>" | tail -n 1 | wc -c

## Q7: How many nucleotides are in the sequence for 'chromosome 5'?

grep "chromosome" -A 1 GCF_000001735.4_TAIR10.1_genomic.fna | grep -v "^>" | tail -n 1 | wc -c


## Q8: How many sequences contain "AAAAAAAAAAAAAAAA"?

grep "AAAAAAAAAAAAAAAA" GCF_000001735.4_TAIR10.1_genomic.fna | wc -l

## Q9: If you were to sort the sequences alphabetically, which sequence (header) would be first in that list? 
### The sort function automatically sorts alphabetically. 

grep "^>" GCF_000001735.4_TAIR10.1_genomic.fna | sort | head -n 1

## Q10: How would you make a new tab-separated version of this file, where the first column is the headers and the second column are the associated sequences? (show the command(s)).
### Since the sequences are on a single line below their header, I can use the paste program in the order I want my columns. I am making a new file named "GCF_000001735.4_TAIR10.1_genomic_columnformat.fna" so I can see the new column formatting. 

paste <(grep "^>" GCF_000001735.4_TAIR10.1_genomic.fna) <(grep -v "^>" GCF_000001735.4_TAIR10.1_genomic.fna) > GCF_000001735.4_TAIR10.1_genomic_columnformat.fna

nano GCF_000001735.4_TAIR10.1_genomic_columnformat.fna


# Task 4
### I've been recording in my text editor as I go!


# Task 5 
## My approach to this assignment is largely saying out loud what I want to happen when I hit enter after creating my stream. Trying to visualize what output I get for one part of the stream and where I need it to go for this stream to keep flowing smoothly was a great help. I also relied heavily on looking back at our class lessons and provided practice to see how we approached certain scenarios. I also used the --help very often to see what all I can do with the programs we have learned. Part of me knew the program I need, I just needed some more help on what else I needed to tell it to get the output I needed. --help really is a blessing. 

## I was very surprised in how often I would use grep and the many ways I can use it. I was a little frustrated when I first started using it, but I definitely got more comfortable the more I used it and the more I read over the --help. 

## I can see how these skills are important in computational biology.  The biggest benefit is it being so efficient. When I do sequencing, I could get different qualities of sequences all in the same file together. When complete and partial sequences are all housed together, I need to be able to find my “good” sequences amongst the possible thousands I have. In this exercise, I could have looked at the 7 headers in the sequence file, but that would take forever for the sequences I get from a real-world sequencing run. Speaking of a sequencing run, I can put different batches of samples on the run. This is true in my lab where samples from different projects can go on the same run. Improving my skills with command line tools will allow me to find sequences for my project way faster than trying to open the sequencing file and find them visually.  I also briefly experienced just how long some sequences can be from the multiple times I accidently made my output be the sequences sent to my screen. If I was looking for sequences with a certain pattern of nucleotides, using grep is a life-saver. Finally, I think trying to do almost anything without these tools would lead to very high human error since you would be bound to miss something even if you printed these sequences out and went over them multiple times to find what you are looking for. 
