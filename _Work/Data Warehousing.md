---
layout: post
title:  "4. Data Warehousing"
category: tech
permalink: /tech/work/warehousing
order: 4
---
# Slowly changing dimensions
1. Type 1 overwrites the existing value with new value and does not retain history

    |  Name    |   ID    | Description |
    | -------- | ------- | ----------- |
    | laptop  | 0    |        xxxx     | 
    | phone | 1    |          yyy      |

    <div style="text-align: center; font-size: 24px; font-weight: bold;">⇓</div>
    &nbsp;

    |  Name    |   ID    | Description |
    | -------- | ------- | ----------- |
    | laptop  | 0    |        zzz     | 
    | phone | 1    |          yyy      |

2. Type 2 add a new role for the new value and maintains the existing row for historical and reporting purposes

    |  Name    |   ID    | Description |
    | -------- | ------- | ----------- |
    | laptop  | 0    |        xxxx     | 
    | phone | 1    |          yyy      |

    <div style="text-align: center; font-size: 24px; font-weight: bold;">⇓</div>
    &nbsp;

    |  Name    |   ID    | Description |
    | -------- | ------- | ----------- |
    | laptop  | 0    |        xxx     | 
    | phone | 1    |          yyy      |
    | laptop  | 0    |        zzz     | 

3. Type 3 allows storage of bith current value and previous vious of the dimension's attributes in the same row, also it has the limited historical tracking. Last description go to prev Description column, updated description goes to current description column, change date reflects the modify time.

    |  Name    |   ID    | Prev Description | Current Description | Change date |
    | -------- | ------- | ---------------- | ------------------- | ----------- |
    | laptop  | 0    |        xxxx     |        zzz               |  2024-04-29 |
    | phone | 1    |          yyy      |        mmm               |  2024-05-01 |
 

