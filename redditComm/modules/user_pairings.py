import json, load_subreddit, collections, sqlparser, output
import load_subreddit_castra, make_subreddit_castra
from pprint import pprint

subreddit_posts = {}

def find(subreddit):
    subreddit_posts = load_subreddit.load(subreddit)
    sub_links = get_links(subreddit_posts)
    users_per_link = {}
    count = 0

    for link in parent_links:
        SQL = """SELECT DISTINCT author FROM May2015 WHERE author != '[deleted]'
        AND subreddit = %s
        AND link_id = %s LIMIT 10"""%("'{}'".format(link['subreddit']),"'{}'".format(link['link_id']))
        print 'Preparing query: '+link['link_id']
        print count
        count += 1
        users_per_link[link['link_id']] = sqlparser.query(SQL)
        users_per_link[link['link_id']].append({"subreddit":link['subreddit']})

    with open('output/results.json', 'w+') as f:
	 	json.dump(users_per_link,f)
    f.closed
    return users_per_link
    return results

def get_links(subreddit_posts):
    parent_links = []
    processed_links = {}
    for post in subreddit_posts:
        if post['link_id'] or post['parent_id'] not in processed_links:
            processed_links[post['link_id']] = post['link_id']

            if post['link_id'] == post['parent_id']:
                d = dict()
                d['link_id'] = post['link_id']
                d['parent_id'] = post['parent_id']
                d['link_type'] = 'root_link'
                d['subreddit'] = post['subreddit']
                parent_links.append(d)

            if post['link_id'] != post['parent_id']:
                d = dict()
                d['link_id'] = post['link_id']
                d['parent_id'] = post['parent_id']
                d['link_type'] = 'child_link'
                d['subreddit'] = post['subreddit']
                parent_links.append(d)
    return parent_links

def test(subreddit):
    # subreddit_posts = load_subreddit.load(subreddit)
    # subreddit_links = get_links(subreddit_posts)
    # pprint(subreddit_posts)
    # make_subreddit_castra.execute(subreddit)
    load_subreddit_castra.load(subreddit)



"""
deprecated

def retrieve_parents(subreddit_posts):
    parent_links = {}
    for post in subreddit_posts:
        if post['link_id'] not in parent_links:
            parent_links['link_id'] = post['link_id']
        if post['link_id'] == post['parent_id']:
            d = dict()
            d['subreddit_id'] = post['subreddit_id']
            d['link_id'] = post['link_id']
            d['subreddit'] = post['subreddit']
            d['name'] = post['name']
            d['author'] = post['author']
            d['body'] = post['body']
            d['score'] = post['score']
            d['created_utc'] = int(post['created_utc'])
            parent_links.append(d)
    # data = sorted(parent_links, key = lambda x:x['created_utc'])
    # with open('boy.json', 'w+') as f:
	# 	json.dump(data,f)
    # f.closed
    # return data
    return parent_links
"""
