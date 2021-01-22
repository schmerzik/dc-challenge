dc-challenge

This repo represents the work done for the challenge.

Dockerfile allows building an image to run all code and tools:
	- Sensitive simple data (environment variables) are kept out of the repo
		- for local builds, they are stored in a file dc_env, passed as a build parameter
		- for cloud builds, they should be provided by the deployment setup
	- Sensitive file data is encrypted - the password is kept in an environment variable, there is a script to auto-decrypt required files

Scripts: this folder contains scripts to perform specific tasks:

0. init-ge.sh - this script contains the most import commands to set up great expecations in advance (creating expectations via Jupyter Notebook)
		this is not meant to be run as is, only serves as a reference

1. init-all.sh - performs all of the following
	
	a. handle-cred.sh: decrypt the sensitive data (requires password in environment, uses the helper/crypt_files.py for actual en/decrypting)

	b. init-dataflow.sh: prepares folder (incl. /src/airflow) & a virtual environment (for DirectRunner, but defaults to DataflowRunner which does not need it)

	c. init-airflow.sh: initializes airflow and its DB: this relies on a Postgres DB in GC
		(postgres to allow parallel execution ; on GC while messing around, could also move it into a part of an image cluster with docker-compose or kubernetes)

	d. init-dbt.sh: sets up the DBT project (re-using the models in /src/dbt/models)

2. To get the data into BigQuery via Dataflow [relies on schema files on gs://challenge-import/schema-*.txt]:

	a. test-dataflow.sh: runs the Dataflow code (see /src/dataflow) on 3 very small sample CSV files into test BigQuery tables

	b. run-dataflow.sh: runs the Dataflow code (see /src/dataflow) on the large CSV files into the main BigQuery tables [will take a bit of time & resources]

3. check-dbt.sh: we use DBT in an Airflow process, but we can check the DB connection

4. To process the source data in BigQuery via Airflow - this uses:
	- GreatExpectations [project incl all configuration already set in pre-made folder]
	- DBT
	AND it relies on:
	- Postgres DB (airflow-db) in GC --> this could be handled by deploying this app in a cluster with a dependency on a small pg container

	a. test-airflow.sh: runs the Airflow project on the 3 small test tables

	b. run-airflow.sh: runs the Airlfow project on the 3 main tables [will take a bit of time & resources]

	c. start-airflow-prod.sh: starts the Airflow webserver and scheduler
		if the DAGs were configured for a scheduled run, they would now be picked up at the requested intervals (we didn't fill in the schedule, only manual for this challenge)
		if you mapped the ports on the container, you could now access the Airflow server for monitoring etc



4. check-customer-clustering.sh: creates a ML model for customer clustering
--> this is run ad hoc. It could be included in the previous flow for automation.

5. check-sales-series.sh: creates a ML model for predicting sales
--> this is run ad hoc. It could be included in the previous flow for automation.