#/bin/bash

# NOTE: this file runs DBT, though this is actually handled by airflow so not required
cd /usr/src/challenge/dbt_challenge_test
dbt run
