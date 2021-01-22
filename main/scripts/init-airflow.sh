#/bin/bash

# NOTE: this file is used to setup airflow
# ASSUMPTION: the Postgres DB itself has already been setup correctly (with connection details in environment)
# this requires running the following on the DB:
	# CREATE DATABASE airflow;
	# CREATE USER airflow;
	# GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

echo "--> Initializing airflow..."

# setup airflow
airflow db init
airflow users create --username $CHALLENGE_AF_ADMIN \
    --firstname First --lastname Last --role Admin \
    --email $CHALLENGE_AF_MAIL --password $CHALLENGE_AF_PASS


# pretty much everything is already set (via environment)
# but now the DAG spec itself:
rm -r /usr/src/challenge/airflow/dags
mkdir /usr/src/challenge/airflow/dags
cp /usr/src/challenge/src/airflow/prep-analysis.py /usr/src/challenge/airflow/dags/prep-analysis.py
cp /usr/src/challenge/src/airflow/prep-analysis-test.py /usr/src/challenge/airflow/dags/prep-analysis-test.py

echo "--> Initializing airflow - done"
