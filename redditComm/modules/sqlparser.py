#!/bin/python
import sqlite3
import json
import subreddit_dumps

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def create_connection():
	conn = sqlite3.connect("./subreddit_dumps/database.sqlite")
	conn.row_factory = dict_factory
	return conn

def query(SQL):
	conn = create_connection()
	cursor = conn.cursor()
	cursor.execute(SQL)
	results = cursor.fetchall()
	conn.close()
	return results
