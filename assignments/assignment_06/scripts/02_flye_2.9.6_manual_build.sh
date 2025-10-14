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

