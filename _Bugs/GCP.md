---
layout: post
title:  "3. GCP"
category: tech
permalink: /tech/bugs/gcp
order: 3
---
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

2. GCP BigQuery schema not equal
```
select ... from ... where id <> 1
```