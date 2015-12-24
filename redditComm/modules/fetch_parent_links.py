import json, load_subreddit, collections

def retrieve(subreddit):
    subreddit_posts = load_subreddit.load(subreddit)
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
    data = sorted(parent_links, key = lambda x:x['created_utc'])
    with open('boy.json', 'w+') as f:
		json.dump(data,f)
    f.closed
    return data
