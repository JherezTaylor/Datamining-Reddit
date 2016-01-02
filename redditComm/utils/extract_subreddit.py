"""This module accepts the name of a subreddit as an argument
and selects and dumps all the records in the subreddit as a json object.
Run it with python extract_subreddit.py <subreddit> <file_type> (without brackets)"""

#!/bin/python
import sqlite3, json, logging, os
import cPickle as pickle
from time import time
from sys import argv

script, subreddit, file_type = argv

logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging.getLogger('requests').setLevel(logging.CRITICAL)
logger = logging.getLogger(__name__)

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def dump_file(subreddit,results,file_type):
    if file_type == 'pickle':
        f = open('../subreddit_dumps/'+subreddit+'_dump.pkl', 'wb')
        pickle.dump(results, f)
        f.close()

    if file_type == 'json':
        with open('../subreddit_dumps/'+subreddit+'_dump.json', 'w+') as f:
    	       json.dump(results,f)
        f.closed

def main():
    connection = sqlite3.connect("../subreddit_dumps/database.sqlite")
    connection.row_factory = dict_factory
    cursor = connection.cursor()

    print "Executing query "+subreddit

    SQL = """SELECT * FROM May2015
    WHERE subreddit = %s"""%("'{}'".format(subreddit))

    ts = time()
    cursor.execute(SQL)
    results = cursor.fetchall()

    if file_type == 'pickle':
        dump_file(subreddit, results, file_type)
    elif file_type == 'json':
        dump_file(subreddit, results, file_type)

    print('Query for '+subreddit+' took {}s'.format(time() - ts))
    connection.close()

if __name__ == '__main__':
   main()
