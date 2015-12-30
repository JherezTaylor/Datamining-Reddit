"""This module accepts dumps all the records in the dataset as a json object.
Run it with python extract_fulldb.py"""

#!/bin/python
import sqlite3, json, logging, os, re
from time import time
from multiprocessing.pool import Pool

logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging.getLogger('requests').setLevel(logging.CRITICAL)
logger = logging.getLogger(__name__)

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def slugify(value):
    """
    Convert to ASCII if 'allow_unicode' is False. Convert spaces to hyphens.
    Remove characters that aren't alphanumerics, underscores, or hyphens.
    Convert to lowercase. Also strip leading and trailing whitespace.
    """
    import unicodedata
    value = unicodedata.normalize('NFKD', value).encode('ascii', 'ignore')
    value = unicode(re.sub('[^\w\s-]', '', value).strip().lower())
    value = unicode(re.sub('[-\s]+', '-', value))
    return value

def get_subreddit_list():
    with open('subreddit_list.json', 'r') as f:
        data = json.load(f)
    f.closed
    return data

def dump_file(subreddit,results):
    with open('subreddit_dumps/json/'+subreddit+'.json', 'w+') as f:
        json.dump(results,f)
    f.closed

def run_query(subreddit):
    connection = sqlite3.connect("subreddit_dumps/database.sqlite")
    connection.row_factory = dict_factory
    cursor = connection.cursor()

    sub = subreddit['subreddit']
    SQL = """SELECT * FROM May2015
    WHERE subreddit = %s LIMIT 10"""%("'{}'".format(sub))
    print "Executing query "+sub

    cursor.execute(SQL)
    results = cursor.fetchall()
    dump_file(slugify(sub),results)
    connection.close()

def main():
    subreddit_list = get_subreddit_list()
    ts = time()
    p = Pool(processes = 2)
    p.map(run_query, subreddit_list)
    print('Full extract took {}s'.format(time() - ts))

if __name__ == '__main__':
   main()
