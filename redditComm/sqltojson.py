"""This module accepts the name of a subreddit as an argument
and selects and dumps all the records in the subreddit as a json object.
Run it with python sqltojson.py <subreddit> (without brackets)"""

#!/bin/python
import sqlite3, json, logging, os
import cPickle as pickle
from time import time
# from sys import argv

# script, subreddit = argv

logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging.getLogger('requests').setLevel(logging.CRITICAL)
logger = logging.getLogger(__name__)

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def main():
    connection = sqlite3.connect("subreddit_dumps/database.sqlite")
    connection.row_factory = dict_factory
    cursor = connection.cursor()

    subreddit_list = ['nba','hockey','nfl','soccer','baseball']
    for sub in subreddit_list:
        ts = time()

        print "Executing query "+sub
        SQL = 'SELECT * FROM May2015 WHERE subreddit = %s'%("'{}'".format(sub))
        cursor.execute(SQL)
        results = cursor.fetchall()

        f = open('subreddit_dumps/'+sub+'_dump.pkl', 'wb')
        pickle.dump(results, f)
        f.close()
        print('Query for 'sub+' took {}s'.format(time() - ts))

        # with open(sub+'_dump.p', 'w+') as f:
    	#        json.dump(results,f)
        # f.closed

    connection.close()

if __name__ == '__main__':
   main()
