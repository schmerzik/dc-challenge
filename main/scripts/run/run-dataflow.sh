#/bin/bash

# NOTE: this file is configured to load the much smaller sample csv files into a test database
#       to actually run the large tables, you will need to edit at least
#       - gsfile parameter for the source CSV
#       - table parameter for the target

RUNNER="DataflowRunner"

# go to separate folder for this work
cd /usr/src/challenge/dataflow/virt
source ./bin/activate

if [ $# = 1 && $1 = "direct" ]; then
	# Use direct runner instead of DataflowRunner
	RUNNER="DirectRunner"
fi

echo "--> Running dataflow with $RUNNER"

cd ..

# we've already create the python script to specify the Dataflow pipeline - we can run it now
# once for the 3 types of data
python3 ./init-data.py --gsfile gs://crunch-demo-retail-data/large/products/products.csv \
	--bq-dataset source --table products --region europe-west1 \
	--temp_location gs://challenge-import/tmp --project nomadic-asset-268508 \
	--service_account_email challenge@nomadic-asset-268508.iam.gserviceaccount.com \
	--schema gs://challenge-import/schema-products.txt --disk_size_gb=80 --runner $RUNNER

python3 ./init-data.py --gsfile gs://ccrunch-demo-retail-data/large/customers/customers-00*.csv \
	--bq-dataset source --table customers --region europe-west1 \
	--temp_location gs://challenge-import/tmp --project nomadic-asset-268508 \
	--service_account_email challenge@nomadic-asset-268508.iam.gserviceaccount.com \
	--schema gs://challenge-import/schema-customers.txt --disk_size_gb=80 --runner $RUNNER

python3 ./init-data.py --gsfile gs://crunch-demo-retail-data/large/orders/orders-00*.csv \
	--bq-dataset source --table orders --region europe-west1 \
	--temp_location gs://challenge-import/tmp --project nomadic-asset-268508 \
	--service_account_email challenge@nomadic-asset-268508.iam.gserviceaccount.com \
	--schema gs://challenge-import/schema-orders.txt --disk_size_gb=80 --runner $RUNNER

# exit virtual environment again
if [ $# = 1 && $1 = "direct" ]; then
	deactivate
fi

echo "--> Finished running dataflow"
