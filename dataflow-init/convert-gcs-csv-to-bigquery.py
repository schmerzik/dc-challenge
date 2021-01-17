# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import logging
import re
import apache_beam as beam
import cloudstorage as gcs
from apache_beam.options.pipeline_options import PipelineOptions

class ReadDataElement:
    def parse(self, input, fields):
        values = re.split(",", re.sub('"', '', re.sub('\r\n', '', input)))
        row = dict(zip(fields,values))
        # if table == 'customers':
        #     row = dict(zip(('Id', 'Gender', 'FirstName', 'LastName', 'PostalCode', 'City', 'StreetAddress', 'Email'),values))
        # if table == 'orders':
        #     row = dict(zip(('OrderLineId', 'OrderId', 'CustomerId', 'ProductId', 'Quantity', 'Datetime'),values))
        return row
    def getFieldTupleFromSchema(schema):
        raw_parts = schema.split(',')
        parsed_parts = []
        for raw_part in raw_parts:
            parsed_parts.append(schema.split(':')[0])
        return tuple(parsed_parts)

def run(argv=None):
    # setup args data & helper class
    parser = argparse.ArgumentParser()
    readDataElement = ReadDataElement()

    # --gsfile: gs file(s) descriptor
    parser.add_argument(
        '--gsfile',
        dest='gsfile',
        required=True)

    # --bq: bq
    parser.add_argument('--bq',
                        dest='bq',
                        required=True)

    # --schema: file with data schema
    parser.add_argument('--schema',
                        dest='schema',
                        required=True)

    # --table: table
    parser.add_argument('--table',
                        dest='table',
                        required=True)

    my_args, other_args = parser.parse_known_args(argv)

    schema = None
    try:
        print("try reading: '" + my_args.schema + "'")
        gcs_file = gcs.open(my_args.schema)
        schema = gcs_file.read()
        print("schema: '" + schema + "'")
        gcs_file.close()
    except Exception as e:
        print(e)
    if schema is None:
        raise Exception('invalid schema file: ' + my_args.schema)
    fields = readDataElement.getFieldTupleFromSchema(schema)

    # schema = None
    # if my_args.table == 'products':
    #     schema='Id:INTEGER,ProductName:STRING,EAN:STRING,Supplier:STRING,Weight:FLOAT,Price:FLOAT'
    # if my_args.table == 'customers':
    #     schema='Id:INTEGER,Gender:STRING,FirstName:STRING,LastName:STRING,PostalCode:INTEGER,City:STRING,StreetAddress:STRING,Email:STRING'
    # if my_args.table == 'orders':
    #     schema='OrderLineId:INTEGER,OrderId:INTEGER,CustomerId:INTEGER,ProductId:INTEGER,Quantity:FLOAT,Datetime:TIMESTAMP'
    # if schema is None:
    #     raise Exception('invalid table')

    # pipeline
    p = beam.Pipeline(options=PipelineOptions(other_args))

    (p
     # Read the file line by line and then convert the data to be understandable by BigQuery and write it
     | 'Read single line from csv: ' + my_args.gsfile >> beam.io.textio.ReadFromText(my_args.gsfile, skip_header_lines=1)
     | 'Convert to BigQuery' >> beam.Map(lambda s: readDataElement.parse(s, fields))
     | 'Write to BigQuery: ' + my_args.table >> beam.io.Write(
         beam.io.BigQuerySink(
             my_args.bq+'.'+my_args.table,
             # simple schema:
             # fieldName:fieldType
             schema=schema,
             create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
             write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND)))
    p.run().wait_until_finish()


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()