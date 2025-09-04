### Navigate into your BIOCOMPUTING repository. I am using relative file paths since where my BIOCOMPUTING repository is housed may be different from yours. For example, mine is stored in Users while someone else may have it in their Desktop. Using the cd program makes BIOCOMPUTING your current directory. 

cd ./BIOCOMPUTING/

### Within BIOCOMPUTING, we can create a new subdirectory. ./BIOCOMPUTING/assignments/ should already exist. Check by using the ls program.

ls

### To make the new subdirectory, we must first make ./BIOCOMPUTING/assignments our current directory. 

cd assignments/

### And now we use mkdir to create the new subdirectory named assignment_1.

mkdir assignment_1

### Now lets move into that new subdirectory. 

cd assignment_1/

### So we have used mkdir to make a single new subdirectory, but we can also use it to make multiple at once. 

mkdir data scripts results docs config logs 

### Do a sanity check by checking what is your current working directory. 

pwd

### Let’s do a double sanity check and make sure that those multiple subdirectories actually exist. 

ls 

### In the ./BIOCOMPUTING/assignments/assignment_1/ subdirectory, we also want to have two files: assignment_1_essay.md and README.md. To create these files, we will use the touch program. This program creates a blank file if it doesn't exist or updates the time stamp if it does exist. 

touch assignment_1_essay.md README.md

### Time to triple sanity check! Make sure that the files were actually created by using ls again.

ls

### Let make two more subdirectories since it is not a good idea to house raw data and clean data in the same place. 

cd data/

mkdir raw clean

### So that all of our new subdirectories appear on our personal course GitHub repository, each subdirectory needs a placeholder file. We will start by doing this in ./BIOCOMPUTING/assignments/assignment_1/data/raw/. **Keep in mind that proper file names are very very important.**

cd raw/

touch raw_01.txt

### Now go back one directory and move into ./BIOCOMPUTING/assignments/assignment_1/data/clean/.

cd ..

cd clean/

touch clean_01.txt

### We still have five other subdirectories that need placeholder files. There is probably a loop we can make to quickly add files, but that is unknown to me. Instead, we will manually move our way in and out of these directories to make their respective placeholder files. Since I am getting used to coding, I will be checking the creation of all my files with the ls program. 

cd ../..

cd scripts/

touch script.sh

ls

cd ..

cd results/

touch result_01.txt

ls

cd ..

cd docs/

touch proposal_draft_01.txt

ls

cd ..

cd config/

touch config_01.txt

ls

cd ..

cd logs/

touch logfile.log

ls

cd ..
	
### We are back in  ./BIOCOMPUTING/assignments/assignment_1/.

### At this point, I will edit my README.md file to include all of the commands I used to create my project structure. **All steps after this are just outlining how I edited my markdown files and submitted my assignment with git add, git commit, and git push.** 

nano README.md

### After editing, use CTRL+O, ENTER, and CTRL+X. This will take you back out of the nano window. 

### I will now enter my assignment_1_essay.md to complete my essay. 

nano assignment_1_essay.md

### After editing, use CTRL+O, ENTER, and CTRL+X. This will take you back out of the nano window. 

### Now it's finally time to submit the assignment by getting all of the files onto our personal GitHub repositories. Make ./BIOCOMPUTING/ your cd again

cd ../../

git status

git add assignments/assignment_1/

git commit -m “Add Assignment 1: Project structure and rationale. I have included detailed notes on how to reproduce my file structure and add the assignment to GitHub.”

git push


# We did it! (hopefully)
