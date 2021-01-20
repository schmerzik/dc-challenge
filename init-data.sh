#/bin/bash

# NOTE: this file is configured to load the much smaller sample csv files into a test database
#       to actually run the large tables, you will need to edit at least
#       - gsfile parameter for the source CSV
#       - table parameter for the target

strLocal = "local"
strCloud = "cloud"


if [ $# != 2 ]; then
	echo "Script requires exactly one parameter, either 'local' or 'cloud'"
	exit 1
fi


# go to separate folder for this work
cd ./dataflow-init

# We use Dataflow to load in data from GCS to BigQuery, relying on Apache Beam
if [ $1 == $strLocal ]; then
	# To run this locally (DirectRunner), we need an active virtual environment
	# so let's create & activate it (should check if already exists and reuse, but that's for production)
	virtualenv /virt
	. virt/bin/activate

	# now in the virtual environment, install apache beam, including the GCP related libraries
	# (all other requirements are already handled by docker & requirements.txt)
	python3 -m pip install apache-beam[gcp]
else
	if [ $1 != $strCloud ]
		echo "Script requires exactly one parameter, either 'local' or 'cloud'"
		exit 1
	fi
fi

# we've already create the python script to specify the Dataflow pipeline - we can run it now
python3 init-data.py --gsfile gs://challenge-import/sample_orders*.csv \
	--bq-dataset source --table orders_test --region europe-west1 \
	--temp_location gs://challenge-import/tmp --project nomadic-asset-268508 \
	--service_account_email challenge@nomadic-asset-268508.iam.gserviceaccount.com \
	--schema gs://challenge-import/schema-orders.txt --disk_size_gb=80

# exit virtual environment again
if [ $1 == $strLocal ]; then
	deactivate
fi