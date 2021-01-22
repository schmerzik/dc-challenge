#/bin/bash

# runs the airflow process (once) on the test data (small tables)

printf -v CURR_DATE '%(%Y-%m-%d)T\n' -1

cd /usr/src/challenge/airflow

airflow dags test prep-analysis-test $CURR_DATE