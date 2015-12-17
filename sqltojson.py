#!/bin/python
 
import sqlite3
import json
 
def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d
 
connection = sqlite3.connect("sample.db")
connection.row_factory = dict_factory
 
cursor = connection.cursor()
 
cursor.execute("select * from sample")
 
# fetch all or one we'll go for all.
 
results = cursor.fetchall()

with open('workfile', 'w+') as f:
	json.dump(results,f)
f.closed
 
connection.close()