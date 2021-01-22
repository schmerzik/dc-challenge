#/bin/bash

echo "--> Initializing DBT..."

# NOTE: this file is used to setup DBT - we create a test (linked to small DBs for testing) and a main project (linked to full size DBs)

# TEST
rm -r /usr/src/challenge/dbt_challenge_test
dbt init dbt_challenge_test --adapter=bigquery

# overwrite project file
cp /usr/src/challenge/helper/dbt/dbt_test_project.yml /usr/src/challenge/dbt_challenge_test/dbt_project.yml
# remove default models & substitute in project models
rm -r /usr/src/challenge/dbt_challenge_test/models/*
cp -r /usr/src/challenge/src/dbt/models_test/* /usr/src/challenge/dbt_challenge_test/models

# MAIN
rm -r /usr/src/challenge/dbt_challenge
dbt init dbt_challenge --adapter=bigquery

# overwrite project file
cp /usr/src/challenge/helper/dbt/dbt_project.yml /usr/src/challenge/dbt_challenge/
# remove default models & substitute in project models
rm -r /usr/src/challenge/dbt_challenge/models/*
cp -r /usr/src/challenge/src/dbt/models/* /usr/src/challenge/dbt_challenge/models

echo "--> Initializing DBT - done"
