#/bin/bash

# NOTE: this is not a fully automated script. Manually run the commands to set up great_expectations project

cd /usr/src/challenge/
great_expectations init

# create suite
great_expectations suite scaffold products

# create an expectation (ensure port 8081 is mapped)
jupyter notebook --allow-root --no-browser --port=8081 --ip=0.0.0.0 --NotebookApp.token=''

# create checkpoint
great_expectations checkpoint new products.chk

# run the checkpoint
great_expectations checkpoint run products.chk


