"""In the event that extract_fulldb.py fails or hangs at some point during its run
then this script will check what files were already processed and give you a json
file to resume from"""
import json, os, glob

def get_subreddit_list():
    data = []
    try:
        with open('subreddit_list.json', 'r') as f:
            data = json.load(f)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
    else:
        f.closed
        return data

def get_made_files():
    read_files = glob.glob("subreddit_dumps/json/*.json")
    return read_files

def create_new_list(made_files):
    result = []
    for m in made_files:
        drive, path = os.path.splitdrive(m)
        path, filename = os.path.split(path)
        name = os.path.splitext(filename)[0]
        obj = {"subreddit": name}
        result.append(obj)
    with open('processed.json', 'w+') as f:
        json.dump(result,f)
    f.closed
    with open('processed.json', 'r') as f:
        data = json.load(f)
    return data

def main():
    subreddit_list = get_subreddit_list()
    made_files = get_made_files()
    made_files = create_new_list(made_files)

    subreddit_list_dict = {}
    for sub in made_files:
        subreddit_list_dict.update({sub['subreddit']: sub['subreddit']})

    output = {}
    for s in subreddit_list:
        if s['subreddit'] not in subreddit_list_dict:
            output.update({s['subreddit']: s['subreddit']})

    with open('diff.json', 'w+') as f:
        json.dump(output,f)
    f.closed
    print len(subreddit_list)
    print len(made_files)
    print len(output)
    # print subreddit_list_dict
    # hey = compare_lists(subreddit_list, made_files)
    # print hey



if __name__ == '__main__':
   main()
