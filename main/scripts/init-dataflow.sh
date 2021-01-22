#/bin/bash

# NOTE: this file is configured to load the much smaller sample csv files into a test database
#       to actually run the large tables, you will need to edit at least
#       - gsfile parameter for the source CSV
#       - table parameter for the target

echo "--> Initializing dataflow..."

# go to separate folder for this work (delete folder if already exists)
rm -r /usr/src/challenge/dataflow
mkdir /usr/src/challenge/dataflow
cp /usr/src/challenge/src/dataflow/init-data.py /usr/src/challenge/dataflow/init-data.py
cd /usr/src/challenge/dataflow

# now install apache beam, including the GCP related libraries (virtual env)
# (all other requirements are already handled by docker & requirements.txt)
virtualenv ./virt
cd ./virt
source ./bin/activate

python3 -m pip install apache-beam[gcp]
deactivate

echo "--> Initializing dataflow - done"
