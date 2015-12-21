#!/bin/python
import sqlite3
import json
 
def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def create_connection():
	conn = sqlite3.connect("database.sqlite")
	conn.row_factory = dict_factory
	return conn

def fetch_parent_links():
	conn = create_conn()
	cursor = conn.cursor()
	
	SQL = """SELECT parent_id, author
			FROM May2015 WHERE subreddit = 'nba'"""
	cursor.execute(SQL)
	
	results = cursor.fetchall()
	conn.close()
	with open('database_dump.json', 'w+') as f:
		json.dump(results,f)
	f.closed
 
	conn.close()
	return results

def fetch_authors_on_link(parent_links):
	author_list = []
	conn = create_conn()
	cursor = conn.cursor()

	for ID in parent_links:
		SQL = """SELECT * FROM May2015 
			WHERE parent_id = %s"""

		print 'Retrieving authors on post %s' % ID
		data = parent_links['parent_id']
		cursor.execute(SQL,data)

		for row in cursor:
			d = dict()
			author_list.append(d)

	print 'Query complete, closing conn'
    conn.close()

if __name__ == '__main__':
	fetch_parent_links()