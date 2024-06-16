---
layout: post
title:  "3. GCP"
category: tech
permalink: /tech/bugs/gcp
order: 3
---

# Note
1. For pass the parameters bewteen airflow and dataflow job, rememeber to keep it short, otherwise will exceed [the hard limit of Google API request length](https://cloud.google.com/knowledge/kb/error-400-bad-request-request-payload-size-exceeds-the-limit-000004321#:~:text=The%20error%20Request%20payload%20size,limit%20and%20cannot%20be%20increased.)

2. To debug, do not use print statement, use logging library, which will show the string in the GCP log. 

3. Note that if the string passed into GCP is timestamp format and the BigQuery table schema is timestamp, GCP will automatically convert that string into timetsamp type.
    ```
    time_sr = "2024-04-04T16:03:00+00:00"
    ```

4. GCP BigQuery query not equal
    ```
    select ... from ... where id <> 1
    ```
5. use bq command line in shell script to query the data, if there is multi queries, please use EOQ instead of triple quotes.
   Triple quotes is for muti-line queries, but not for multi queries.

    ```
    bq query --use_legacy_sql=false <<EOQ
    ...
    EOQ
    ```

# Dataflow
1. This error means the loaded data does not match the schema, the root cause would be the type mismatch. 
In order to match the data with the BigQuery table schema, the column names should be the same, not case sensitive. 
Noted that if some fields in schema you do not have in data it is fine, GCP will automatically mark value as None.
Usually for debugging, the way I use is binary search, search half to check if error occurs, then recursive check for half half etc.
    ```
    message: 'Error while reading data, error message: JSON table 
    encountered too many errors, giving up. Rows: 1; errors: 1. 
    Please look into the errors[] collection for more details.'
    ``` 
To reproduce this issue in nonprod environment, remember to make sure the filter condition in the query satys the same so that the error data will be extracted to reproduce the error.

2. This error showed that the upper limit to update a GCP BigQuery table is 20. If the dataflow job failed due to this, we can set the retry number to rerun dataflow job to avoid error.
    ```
    Too many DL statement outstanding against table .... limit is 20.
    ```

# Logs Explorer
To check dataflow customized log, either in dataflow job, or we can check through Logging resource.
1. Go to Log Analyics 
2. Set the time back to avoid missing records
3. input query, the customized logging statement will be in json_payload column which contains instruction as a key.
    ```
    select text_payload, json_payload from `...` where string(resource.label_name) = "..."
    and json_payload is not null and JSON_EXTRAC(json_payload, '$.instruction') is not null 
    order by timestamp desc
    ```

# Batch
Pyhon Oracledb package, the error like that indicates that for one column, data may be missing for some of the records, check [link](https://github.com/oracle/python-oracledb/issues?q=is%3Aissue+dpy-3013).
    ```
    DPY-3013 unsupported Python type *** for database type DB_TYPE_VARCHAR
    ```

# BigQuery
In BigQuery, date type represents string that contains only date information such as "2024-06-01", while timestamp type can either be a string like "2024-06-01T17:00:00+00.00" or python datetime object. these two cannot be mixed.