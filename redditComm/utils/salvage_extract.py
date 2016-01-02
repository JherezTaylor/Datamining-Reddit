"""
    In the event that extract_fulldb.py fails or hangs at some point during
    its run then this script will check what files were already processed and
    give you a json file to resume from
"""
import json, os, glob, re
from difflib import SequenceMatcher

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
    """
    Read the master list of subreddits, returns two lists. One with the
    raw subreddit names as the appear in the database and the other with
    the santized file name safe versions
    """
    data = []
    raw_list = []
    safe_list = []
    try:
        with open('subreddit_list.json', 'r') as f:
            data = json.load(f)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
    else:
        f.closed
        for s in data:
            raw_list.append(s['subreddit'])
            safe_list.append(str(slugify(s['subreddit'])))
        return raw_list, safe_list

def get_made_files():
    """
    Returns the contents of the folder where the subreddit dumps are stored as
    json files.
    """
    read_files = glob.glob("../subreddit_dumps/json/*.json")
    return read_files

def create_new_list(made_files):
    """
    Takes a list of files and removes the drive and path and extension, only
    returning a list of strings with the file names.
    """
    result = []
    for m in made_files:
        drive, path = os.path.splitdrive(m)
        path, filename = os.path.split(path)
        name = os.path.splitext(filename)[0]
        result.append(str(name))
    return result

def main():
    raw_list, safe_list = get_subreddit_list()
    made_files = get_made_files()
    processed_list = create_new_list(made_files)

    raw_list.sort()
    safe_list.sort()
    processed_list.sort()

    setA = set(safe_list)
    setB = set(processed_list)
    diff = setA.difference(setB)

    print 'Total: '+str(len(setA))
    print 'Processed: '+str(len(setB))
    print 'Remaining: '+str(len(diff))

    # After we get the subreddits that weren't processed, let's get the
    # their raw strings as the appear in the database.
    query_list = []
    for x in raw_list:
        if slugify(x) in diff:
            query_list.append({"subreddit": x})

    with open('unprocessed_list7.json', 'w+') as f:
        json.dump(query_list,f)
    f.closed

if __name__ == '__main__':
   main()
