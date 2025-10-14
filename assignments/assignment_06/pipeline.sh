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
