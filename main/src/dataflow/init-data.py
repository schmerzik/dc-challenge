import argparse
import logging
import re
import json
from io import StringIO
import apache_beam as beam
from apache_beam.io.gcp.internal.clients import bigquery
from apache_beam.options.pipeline_options import PipelineOptions

class ReadDataElement:
    def parse(self, input, fields, types):
        # parse the line, there can be empty values, quoted strings (which in turn include the delimiter ,)
        regexMatches = re.findall(r'(^(?=,))|((?<=\")[^\"]*(?=\",))|((?<=,\")[^\"]*(?=\"))|((?<=,)(?=,))|([^\",]+(?=,))|(?<=,)([^\",]*$)',input)

        if len(regexMatches) != len(fields):
            raise Exception('Row length does not match schema fields length')

        idx = 0
        values = []
        for itemTuple in regexMatches:
            val = ''.join(itemTuple)
            if val == '':
                val = None
            values.append(val)
            idx = idx + 1

        row = dict(zip(tuple(fields),tuple(values)))
        return row

    def getSchemaDict(self, schema):
        # cols = json.loads(schema)['fields']#['BigQuery Schema']
        fields = []
        types = []
        # for col in cols:
        #     fields.append(col['name'])
        #     types.append(col['type'])
        # return [fields,types]
        schema_list = [s.strip() for s in schema.split(',')]
        for field_and_type in schema_list:
            field_name, field_type = field_and_type.split(':')
            fields.append(field_name)
            types.append(field_type)
        return [fields,types]

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
    parser.add_argument('--bq-dataset',
                        dest='dataset',
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
        gcs_file = beam.io.gcp.gcsio.GcsIO().open(my_args.schema)
        # gcs_file = gcs.open(my_args.schema)
        schema = str(gcs_file.read(), "utf-8")
        gcs_file.close()
    except Exception as e:
        logging.error('Schema invalid or unspecified: %s', e)
        raise e
    
    fields, types = readDataElement.getSchemaDict(schema)

    table_spec = bigquery.TableReference(
        projectId='nomadic-asset-268508',
        datasetId=my_args.dataset,
        tableId=my_args.table)


    p = beam.Pipeline(options=PipelineOptions(other_args))

    print("STARTING")
    (p
     # Read the file line by line and then convert the data to be understandable by BigQuery and write it
     | 'Read single line from csv' >> beam.io.textio.ReadFromText(my_args.gsfile, skip_header_lines=1)
     | 'Convert to BigQuery' >> beam.Map(lambda s: readDataElement.parse(s, fields, types))
     #| 'Debug' >> beam.Map(lambda item: print("DEBUG print ({}) item {}".format(type(item),item)))
     | 'Write to BigQuery' >> beam.io.WriteToBigQuery(
            table_spec,
            schema=schema,
            insert_retry_strategy='RETRY_ON_TRANSIENT_ERROR',
            write_disposition='WRITE_APPEND',
            create_disposition='CREATE_IF_NEEDED'))

    try:
        p.run().wait_until_finish()
    except Exception as e:
        logging.error('Pipeline issue: %s', e)
        raise e

if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()