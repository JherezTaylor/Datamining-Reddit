"""This module accepts the name of a prefetched subreddit json dump
and loads and returns its contents as an object."""
import subreddit_dumps, json

def load(subreddit):
    with open('./subreddit_dumps/'+subreddit+'_dump.json', 'r') as f:
        data = json.load(f)
    f.closed
    return data
