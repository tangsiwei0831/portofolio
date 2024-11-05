---
layout: post
title:  "5. Apache Airflow"
category: tech
permalink: /tech/work/airflow
order: 5
---
# Cmommon Knowledge
1. Data pipeline has two types, **streaming** and **batch**. Steaming data pipeline is real time and bacth data pipeline 
   is scheduled. Therefore, to update DAG, streaming pipeline needs to be switched off but batch does not need.
2. **Backfilling**: process of running computation for dates in the past. Typically occurs when new workflows 
   or existing ones are modified, there is a need to generate data for periods before the workflow is active or updated.
   * Reasons for backfilling: new workflow deployment, data pipeline modification, daa loss recovery or consistency across systems
   * Suppoese there is a DAG scheduled to run daily, start date is Jan 1st 2023, and deploy time is Jan 10th 2023. If `catch_up` is true, hen it will run 9 times in a row.

# Scheduling
The DAG running time is based on the start_date and end_date. For example, if I set the DAG to be running every day at 5 am Toronto time. Then if I set catch up parameter to be false, and the start date to be 2024-07-24. Then if I switch on DAG on 7-24, the DAG will not start running immediately, it will start from start_date + schedule_interval which is 24 hours after -25 which is 7-25. Therefore, the job will start at 7-25 5am.

# Sample Airflow structure
```
def create_dag(...):
    ...
default_args={...}
globals()[dag_id] = create_dag(...)
```

# default argument parameter
    ```
    default_args = {
        'owner': ...,
        'project_id': ...,
        'depends_on_past': ...,
        'wait_for_downstream': ...,
        'start_date': ...,
        'end_date': ...,
        ...
    }
    ```

1. When `depends_on_past` is true for a task, it meas the task can only run if the prvious schedule succeeded.
   If a task fails in one run one any day, all ubsequent run of that task will beskipped until the failure is resolved.

2. `wait_for_downstream` is similar to `depends_on_past`, but also requires all downstream tasks in the previous 
   run was successful. 

# create DAG function
    ```
    def create_dag(...):
        with models.DAG(dag_id,schedule_interval=...,tags=...,default_args=...,...,catctup=...) as dag:
            start_dag = bash_operator.BashOperator(...,dag=dag)
            end_dag = DummyOperator(...,dag=dag)
            sfdc_dag = DataflowTemplatedJobStartOperator(...,dag=dag)
            start_dag >> sfdc_dag >> end_dag
        return dag
    ```

1. `catchup` parameter controls the backfilling process, if it is true airflow will attempt to run the DAG 
   for all the intervals between DAG start date and current time (or other end date if specified) that 
   haven't been executed. 
2. Usage of dummy operator, check this 
   [post](https://stackoverflow.com/questions/57036756/what-is-the-usage-of-dummyoperator-in-airflow)

3. `DataflowTemplatedJobStartOperator` is used to create a dataflow template task.
   * In order to pass the schema JSON object, we need to pass the schema in `DataflowTemplatedJobStartOperator`. 
   The schema needs to be passed as JSON string since the operator does not allow any other types to be passed.
   * `impersonation_chain` os used to specify the identity under which the GCP dataflow job should be executed.
   
    ```
    pasword="abc"
    schema = {...}

    tid=DataflowTemplatedJobStartOperator(
        task_id = ...,
        ...,
        impersonation_chain=...,
        options=options,
        parameters={
            "password": password,
            "schema": json.dumps(schema)
        }
    )
    ```

# Note
1. If the DAG schedule is set to be 9:30 am UTC time once every day, then if I switch on the DAG at 12:30 pm, it will immediately starts since it thinks it is late for start.

