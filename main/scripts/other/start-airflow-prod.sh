#/bin/bash

# starts the Airflow webserver and scheduler - any DAGs with schedules will be executed [for challenge, only manual triggers]

cd /usr/src/challenge/airflow
airflow webserver -D --port 8080

airflow scheduler
