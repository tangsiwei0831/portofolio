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

# Errors
1. This error means the loaded data does not match the schema, the root cause would be the type mismatch. 
In order to match the data with the BigQuery table schema, the column names should be the same, not case sensitive. 
Noted that if some fields in schema you do not have in data it is fine, GCP will automatically mark value as None.
Usually for debugging, the way I use is binary search, search half to check if error occurs, then recursive check for half half etc.
```
message: 'Error while reading data, error message: JSON table 
encountered too many errors, giving up. Rows: 1; errors: 1. 
Please look into the errors[] collection for more details.'
``` 
# Need to remember
1. GCP BigQuery query not equal
```
select ... from ... where id <> 1
```