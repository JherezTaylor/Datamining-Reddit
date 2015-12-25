"""This module accepts the name of a subreddit as an argument
and selects and dumps all the records in the subreddit as a json object.
Run it with python sqltojson.py <subreddit> (without brackets)"""

#!/bin/python
import sqlite3
import json
from sys import argv

script, subreddit = argv

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

connection = sqlite3.connect("database.sqlite")
connection.row_factory = dict_factory

cursor = connection.cursor()

SQL = 'SELECT * FROM May2015 WHERE subreddit = %s'%("'{}'".format(subreddit))

cursor.execute(SQL)
# fetch all or one we'll go for all.

results = cursor.fetchall()

with open(subreddit+'_dump.json', 'w+') as f:
	json.dump(results,f)
f.closed

connection.close()
