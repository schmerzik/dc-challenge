#/bin/bash

# Tests the 3 test suites (small tables)
cd /usr/src/challenge/great_expectations

# NOTE: this may fail with a weird error. Worked the first time around, but failed during testing. Found a minor bug in the source code
#       of great_expectations (query_schema is referenced before it is set, but this will always happen for bigquery, as far as I can tell)
#       just setting the query_schema to None in that file, fixed it.
#       maybe a version difference between initial testing and final testing?

great_expectations checkpoint run customers_test_af.chk
great_expectations checkpoint run orders_test_af.chk
great_expectations checkpoint run products_test_af.chk

great_expectations checkpoint run customers.chk
great_expectations checkpoint run orders.chk
great_expectations checkpoint run products.chk