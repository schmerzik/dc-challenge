#/bin/bash

# check connection to test DB
cd /usr/src/challenge/dbt_challenge_test
dbt debug

# check connection with main DB (same DB, different tables, actually)
cd /usr/src/challenge/dbt_challenge
dbt debug
