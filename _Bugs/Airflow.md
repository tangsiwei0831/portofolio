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

In dataflow job, the parameters can be used in several ways. Noted that parameters type is          
            RuntimeValueProvider, so we cannot directly use it in pipeline construction.

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
The parameter password can be retrieved in ParDo transformation by using get method, note that you cannot use get method in init method, will result in error **RuntimeValueProvider: get() not called from a runtime context**
```
class ReadData:
    def __init__(self, password_vp):
        self.password_vp = password_vp

    def process(self, element):
        password = password_vp.get()
        # password is string for now
```
for schema, we cannot use ParDo transformation on WriteToBigQuery function, so use callable to transfer
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
<hr style="border:2px solid gray">
The pipeline will run every 6 hours, therefore, historical data will not be loaded, only new generated data will be loaded. In this case, for the previous pipeline, we need to add a start section to read from bigquery, get the latest load data time, then use this time as a filter value, compared with the new loaded data timestamp, then finally load the data into the truncated bigquery table, this should be a perfect loop.

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
    # to pass this filter_value into next task, you can pass this PTransform object as sideinput into the next task.
    salesforce_records = (
        p | beam.Create([None])
          | beam.ParDo(..., filter_value=beam.pvalue.Assingleton(filter_value))
    )
```
<hr style="border:2px solid gray">
Based on the background, the pipieline runs every six hours, therefore we should only load the delta data, which is the newly generated data insead of historical data. The logic is to use filer_value mentioned before to compare with the source data timestamp to filter out new data. Consider an edge case, if the filtered data is empty Pcollection object, as the assumption, the pipeline should truncae the bigquery table and not load data.

For function `writeToBigQuery`, if input data is empty, the bigQuery table will not be truncated, the old data wil stay in table and nothing changes, therefore, an alternative way needs to be taken in order to truncate table in this edge case.

```
# read all the records from source side, the filter_value will be compared with each record in the data, if data is all old,
# salesforce_records will be in format as {}, {}, ... inside curly bracket
salesforce_records = (...)   

# remove all the inner brackets, and get the number of how many rows it has, in this case, 0
total_rows = (salesforce_records | beam.filter(lambda x: x != {})
                                 | beam.combiners.Count.Globally())


# therefore we can use total row number as condition, if it is 0, truncate, otherwise, not truncate table
should_truncate = (
    p | beam.create([None])
      | beam.ParDo(..., beam.pvalue.Assingleton(total_rows))
)
```


# Note
1. all the task in dataflow job may not in order, it may be parallel, the order is determined by dependency.
In the below code, salesforce_records task must happen after filter_value task, since it depends on the Pvalue. 
total_rows task can be parallel with filter_value task.

```
filter_value = (
    p | beam.io.ReadFromBigQuery(...)
)

salesforce_records =  (
        p | beam.Create([None])
          | beam.ParDo(..., filter_value=beam.pvalue.Assingleton(filter_value))
    ) 

total_rows = (p | ...)
```

