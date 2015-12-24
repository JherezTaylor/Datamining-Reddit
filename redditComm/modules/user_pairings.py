import json, load_subreddit, collections, sqlparser

def find(subreddit):
    subreddit_posts = load_subreddit.load(subreddit)
    parent_links = retrieve_parents(subreddit_posts)
    users_per_link = {}

    for link in parent_links:
        # SQL = 'SELECT DISTINCT author FROM May2015 WHERE subreddit = %s AND link_id = %s'%("'{}'".format(link[subreddit]),"'{}'".format(link[link_id]))
        SQL = "SELECT DISTINCT author FROM May2015 WHERE subreddit ="+("'{}'".format(link['subreddit']))+" AND link_id = "+("'{}'".format(link['link_id']))
        users_per_link[link['link_id']] = sqlparser.query(SQL)

    with open('results.json', 'w+') as f:
	 	json.dump(users_per_link,f)
    f.closed
    return users_per_link

def retrieve_parents(subreddit_posts):
    parent_links = []
    for post in subreddit_posts:
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
