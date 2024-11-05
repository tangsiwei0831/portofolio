---
layout: post
title:  "6. Oracle"
category: tech
permalink: /tech/work/oracle
order: 6
---
# miscellaneous bug
1. DPY-3013: unsupported Python type int for database type DB_TYPE_VARCHAR

    The problem happened due to the data insertion into Orcle DB is separated into different chunks, therefore, for some of the columns, the value may be null for the first chunk, then Oracle database regards tis column as VARCHAR type, which will be conflicted with the real type value (float) later. Check [issue](https://github.com/oracle/python-oracledb/issues/187) for the details.

    According to comments in the link, the issue can be resolved quickly by create a new cursor each chunk. 
    ```
    curr = conn.cursor()
    curr.executemany(query, values)

    curr.close()
    conn.commit()
    ```
