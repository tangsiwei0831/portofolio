---
layout: post
title:  "5. Apache Airflow"
category: tech
permalink: /tech/bugs/airflow
order: 5
---
# Cmommon Knowledge
data pipeline has two types, stream and batch. Steaming data pipeline is real time and bacth data pipeline is scheduled. Therefore, to update DAG, streaming pipeline needs to be switched off but batch does not need.

# Difficulty & Solution
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

# Note
1. If the DAG schedule is set to be 9:30 am UTC time once every day, then if I switch on the DAG at 12:30 pm, it will immediately starts since it thinks it is late for start.