#!/bin/bash
set -ueo pipefail

# count the lines of first argument to the script
# and pipe STDOUT to cut to remove the filename output
wc -l $1 | cut -f 1 -d " "
# returns a number equal to the number of lines in a file
