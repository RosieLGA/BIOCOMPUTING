### Rosie George-Ambrocio
### September 10, 2025
### Assignment 02

### In Task 1, I need to setup a workspace for this course on the HPC. In class, I was able to do this by cloning my BIOCOMPUTING repository straight from GitHub. To begin this process, I first need to log into the HPC. Instead of using ssh yourID@bora.sciclone.wm.edu, I used an alias that I added to ~/.bashrc

nano ~/.bashrc
alias bora='ssh rlgeorgeambroc@bora.sciclone.wm.edu'

## After saving that alias to ~/.bashrc, I closed and reopened my terminal so that the file is sourced. Now I can log into the HPC with my alias and begin to add my repository. I will move into the repository right after. 

bora
git clone https://github.com/yourUserID/BIOCOMPUTING
cd BIOCOMPUTING/

## My BIOCOMPUTING repository currently has the following subfolders: assignments lessons personal_practice practice quizzes README.md test
 
## The lessons and quizzes folders were created during class. Here is where I officially started work for this assignment. I need a few more things so I will make a folder within assignments named assignment_02. assignment_02 exists on my local machine, but I did not get it from cloning my git repository since the folder is empty. I will also put a data folder in assignment_02 and a README.md 

cd assignments
mkdir -p assignment_02/data
touch assignment_02/README.md

### Now I can move to Task 2 where I will download files from NCBI via command-line FTP. The entirety of Task 2 will take place on my local machine. I could have two bash windows open to access my local machine and the HPC at the same time, but I will just log out of the HPC for this assignment. 

logout

## Now in my local machine, I will connect to the NCBI FTP server (ftp.ncbi.nlm.nih.gov)

ftp ftp.ncbi.nlm.nih.gov

## Success! Now I log in as "anonymous" and use my email address as the password. rlgeorgeambroc@wm.edu

## Navigate to: genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/

cd genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/
ls
bye

## At this point I kept getting an error (425 Unable to build data connection: Connection refused). I tried to use multiple online forms and sites to get advice. I messed with my firewall settings and even turned it off for a moment. I kept seeing advice to use lftp, but the suggested methods of obtaining it kept not working for me. As a last resort, I asked ChatGPT how I can get lftp. It suggested I install lftp via MSYS2.

## I downloaded MSYS2. Within MSYS2:
pacman -Syu
pacman -Su
pacman -S lftp


## Regrettably, I did not write down all the successful steps (and there were MANY unsuccessful steps) to getting my lftp installation from MSYS2 to Git Bash. I did have to add the following to my ~/.bashrc within Git Bash. 

export PATH=$PATH:/c/msys64/usr/bin


## When I am back in my local bash, I could not just use lftp followed by the ncbi url. Literally nothing on my screen changed and hitting enter just put me to the next line without a $. I had to do the code below in Git Bash as a test: 

lftp -e "set ftp:passive-mode on; ls; exit" ftp.ncbi.nlm.nih.gov

## This showed me that lftp is functioning, but it was not in interactive mode under Git Bash. I could see the highest order list of folders in this part of ncbi and I could see the genomes directory. I did not have to log in to see any of this. As you can see through my notes, I like writing step-by-step what I do and why. However, me getting what I need from ncbi via Git Bash means I need to get what I can and get right back out. 

# In one go (and I felt like I was grabbing blindly), I navigated into the instructed folder and downloaded the two specified files. 

lftp -e "set ftp:passive-mode on; cd /genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/; get GCF_000005845.2_ASM584v2_genomic.fna.gz; get GCF_000005845.2_ASM584v2_genomic.gff.gz; bye" ftp.ncbi.nlm.nih.gov

## Now the two files are currently sitting in my users. I am so happy that I found something that worked but I will be asking my fellow bioinformaticians in-training how they were able to complete this task if they have a Windows computer.

### I am transitioning to Task 3 now. Here I will transfer files using Filezilla. I am navigating to: ~/BIOCOMPUTING/assignments/assignment_2/data/ and uploading both .gz files that I just downloaded. To do this on Filezilla, I first signed into the HPC from there. I located my downloaded files on the left screen, and I clicked into the data folder within my assignment 2 folder. From there, I was able to drag and drop my files into my data folder. 


## To ensure the files are world-readable, I will check their file permissions in Filezilla by right clicking on them and selecting "file permissions." I only see that owners can read the files but groups and public cannot so I will have to fix this using chmod. 

## In Git Bash, I logged back into the HPC and navigated to ./assignment_02/data

bora
cd BIOCOMPUTING/assignments/assignment_02/data

## Since I want to make the files are readable by everyone, I will the read mode (r) and the group (g) and other (o) classes along with the chmod. I checked to see if this worked in Filezilla by looking at the file permissions again.

chmod go+r GCF_000005845.2_ASM584v2_genomic.fna.gz
chmod go+r GCF_000005845.2_ASM584v2_genomic.gff.gz


### Now onto Task 4: verify file integrity with md5sm. I will do this both on my local machine and the HPC using md5sm and recording the MD5 slashes. 

## First on the HPC: 

md5sum GCF_000005845.2_ASM584v2_genomic.fna.gz
# c13d459b5caa702ff7e1f26fe44b8ad7

md5sum GCF_000005845.2_ASM584v2_genomic.gff.gz
# 2238238dd39e11329547d26ab138be41 

## And now on my local machine. I will open another Git Bash window so that I do not have to sign out and back into the HPC. I need to navigate to where my downloaded files went. Since they went to my users and users is my parent directory when I open Git Bash, I do not have to navigate to any folders. 

md5sum GCF_000005845.2_ASM584v2_genomic.fna.gz
# c13d459b5caa702ff7e1f26fe44b8ad7
md5sum GCF_000005845.2_ASM584v2_genomic.gff.gz
# 2238238dd39e11329547d26ab138be41

## I can visually confirm that the hashes match!


### Time for Task 5: creating useful bash aliases. Within the HPC, I carefully added the listed aliases from the assignment to my ~./bashrc

cd
cd BIOCOMPUTING
nano .bashrc
 
## Back in the terminal, I will run ~/.bashrc to enable the aliases
source ~/.bashrc

## Time to interpret these aliases. 
# alias u='cd ..;clear;pwd;ls -alFh --group-directories-first' This alias first makes me go back one directory. It then clears the screen. Next, it prints my working directory and lists all files in that directory in a long format. It will organize the list by listing directories first. 
# alias d='cd -;clear;pwd;ls -alFh --group-directories-first' This alias changes my directory to the previous working directory. It then clears the screen. Next, it prints my working directory and lists all files in that directory in a long format. It will organize the list by listing directories first. 
# alias ll='ls -alFh --group-directories-first' This alias lists all files in my current directory in a long format. It will organize the list by listing directories first.

### Reflection
# I would say that everything was mostly fine (getting into the HPC, making directories, using Filezilla). Really the biggest problem I had was trying to find a way to get the files I needed from ncbi. That alone took up majority of my time with the assignment. That being said, that would be something I would change in that I would have liked to have had a similar tool to ftp or some instructions on how I can get something close to it. 
