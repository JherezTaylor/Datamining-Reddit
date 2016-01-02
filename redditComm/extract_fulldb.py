"""This module accepts dumps all the records in the dataset as a json object.
Run it with python extract_fulldb.py"""

#!/bin/python
import sqlite3, json, logging, os, re, glob, gc
from modules import make_subreddit_castra
from time import time
from multiprocessing.pool import Pool
from sys import argv

script, file_name = argv

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

def get_subreddit_list(file_name):
    data = []
    try:
        with open('utils/'+file_name+'.json', 'r') as f:
            data = json.load(f)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
    else:
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
    WHERE subreddit = %s"""%("'{}'".format(sub))
    print "Executing query "+str(sub)

    cursor.execute(SQL)
    results = cursor.fetchall()
    dump_file(slugify(sub),results)
    connection.close()

    with open("utils/log_extract.txt", "a") as log:
        log.write(str(sub)+'\n')

def merge_json_dumps():
    count = 1;
    read_files = glob.glob("subreddit_dumps/json/*.json")
    file_path = "subreddit_dumps/merged_file.json"
    with open(file_path, "r+") as outfile:
        for f in read_files:
            print 'File #'+ str(count)
            count = count + 1
            # collected = gc.collect()
            # print "Garbage collection thresholds: " + str(gc.get_threshold())
            # print "Garbage collector: collected " + str((collected)) + " objects."
            with open(str(f), 'r') as data_file:
                    # data = json.load(data_file)
                    json_data = data_file.read().decode('utf-8')
                    outfile.seek(os.stat(file_path).st_size -1)
                    outfile.write(",{}]".format(json.dumps(json_data)))

def main():
    ts = time()
    # subreddit_list = get_subreddit_list(file_name)
    # p = Pool(processes = 1)
    # p.map(run_query, subreddit_list)
    merge_json_dumps()
    # make_subreddit_castra.execute('merged_file')
    print('Full extract took {}s'.format(time() - ts))

if __name__ == '__main__':
   main()
