---
layout: post
title:  "1. Airflow templating pipeline"
category: tech
permalink: /tech/bugs/airflow
order: 1
---
# Structure
Airflow template pipeline consists of three files
* Airflow file for creating DAGS to schedule tasks
* YAML file for as he input configuration for airflow job, including table schema, DAG name etc
* Dataflow file which is called by airflow file to create tasks


# Condition
The dataflow file aims for reading data from source database and then pass data and schema to Google Cloud BigQuery. Since there are many tables in source database, in order to make one dataflow job to matches with all tables, we need to make all variables dynamic instead of hardcoding. So parameter needs to pass from airflow job to dataflow job in order to make every variable dynamic. This question is about the pass of schema, which is JSON format.

# Difficulty & solution
In order to pass the schema JSON object, we need to pass the schema in `DataflowTemplatedJobStartOperator`. 
The schema needs to be passed as JSON string since the operator does not allow any other types to be passed

```
pasword="abc"
schema = {...}

tid=DataflowTemplatedJobStartOperator(
    task_id = ...,
    ...
    parameters={
        "password": password,
        "schema": json.dumps(schema)
    }
)
```

In dataflow job, the parameters can be used in several ways. Noted that parameters type is RuntimeValueProvider, so we cannot directly use it in pipeline construction.

```
# Create subclass of PipelineOptions and then add aruguments
class WorkOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_value_provider_argument(
            "--password",
            type=str,
            help="password"
        )

        parser.add_value_provider_argument(
            "--schema",
            type=str,
            help="schema"
        )
    
# in the run method for pipeline, retrive parameters
def run():
    pipeline_options = PipelineOptions().view_as(WorkOptions)
    pipeline = beam.pipeline(options=pipeline_options)
    with beam.pipeline(options=pipeline_options) as p:
        records = (
            p | "create seed" >> beam.create([None])
              | "Read data" beam.Pardo(ReadData(pipeline_options.password))
        )
```
* The parameter password can be retrieved in ParDo transformation by using get method
```
class ReadData:
    def __init__(self, password_vp):
        self.password_vp = password_vp

    def process(self, element):
        password = password_vp.get()
        # password is string for now
```
* for schema, we cannot use ParDo transformation on WriteToBigQuery function, so use callable to transfer
```
def retrieve_schema(schema_vp, dest):
    schema_str = schema_vp.get()
    return json.loads(schema_str)
def run():
    ...
    records | "write to BigQuery" >> beam.io.WriteToBigQuery(
            table=...,
            schema=lambda dest: retrieve_schema(pipeline_options.schema, dest),
            ...
        )
```
Now, the pipeline will run every 6 hours, therefore, historical data will not be loaded, only new generated data will be loaded. In this case, for the previous pipeline, we need to add a start section to read from bigquery, get the latest load data time, then use this time as a filter value, compared with the new loaded data timestamp, then finally load the data into the truncated bigquery table, this should be a perfect loop.

To extract the filter value, we need to use beam.io.ReadFromBigQuery function. filter_query will be passed as a parameter from airflow to dataflow code, noted that query can either be a static string or valueprovider, in this case, it is a valueprovider. Also, since ReadFromBigQuery function will return value, the value will be stored in a temporary dataset and then be deleted after finish. Since in some case there is no permission to create the temp dataset, thus we set the parameter temp_dataset so that the temporary table will be created in the pointed dataset. 

Noted that the query needs to specify "dataset.table", do not use "project.dataset.table", will cause the return result not as expected. Also, make sure the bigquery is imported from correct module, otherwise will cause error. 
```
from apache_beam.io.gcp.inernal.clients import bigquery
# pipeline_opions.filterQuery = "select ... from xxx.yyy"
# in the run method for pipeline, retrive parameters
def run():
    pipeline_options = PipelineOptions().view_as(WorkOptions)
    pipeline = beam.pipeline(options=pipeline_options)
    with beam.pipeline(options=pipeline_options) as p:
        filter_value = (
            p | "Read from BQ" >> beam.io.ReadFromBigQuery(
                query=pipeline_options.filter_query,
                use_standard_sql=True,
                temp_dataset=bigquery.DatasetReference(projectId="...", dataseId="...")
            )
        )
```

# Note
For pass the parameters bewteen airflow and dataflow job, rememeber to keep it short, otherwise will exceed [the hard limit of Google API request length](https://cloud.google.com/knowledge/kb/error-400-bad-request-request-payload-size-exceeds-the-limit-000004321#:~:text=The%20error%20Request%20payload%20size,limit%20and%20cannot%20be%20increased.)

To debug, do not use print statement, use logging library, which will show the string in the GCP log. 