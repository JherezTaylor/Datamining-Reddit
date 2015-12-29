"""This module accepts dumps all the records in the dataset as a json object.
Run it with python extract_fulldb.py"""

#!/bin/python
import sqlite3, json, logging, os
from time import time

logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging.getLogger('requests').setLevel(logging.CRITICAL)
logger = logging.getLogger(__name__)

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def dump_file(results):
    with open('subreddit_dumps/reddit_data_05-15.json', 'w+') as f:
        json.dump(results,f)
    f.closed

def main():
    connection = sqlite3.connect("subreddit_dumps/database.sqlite")
    connection.row_factory = dict_factory
    cursor = connection.cursor()

    print "Executing query"

    SQL = """SELECT * FROM May2015 LIMIT 10"""

    ts = time()
    cursor.execute(SQL)
    results = cursor.fetchall()

    dump_file(results)
    print('Full extract took {}s'.format(time() - ts))
    connection.close()

if __name__ == '__main__':
   main()
