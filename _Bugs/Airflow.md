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

# Note
For pass the parameters bewteen airflow and dataflow job, rememeber to keep it short, otherwise will exceed [the hard limit of Google API request length](https://cloud.google.com/knowledge/kb/error-400-bad-request-request-payload-size-exceeds-the-limit-000004321#:~:text=The%20error%20Request%20payload%20size,limit%20and%20cannot%20be%20increased.)