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
```
message: 'Error while reading data, error message: JSON table 
encountered too many errors, giving up. Rows: 1; errors: 1. 
Please look into the errors[] collection for more details.'
``` 
