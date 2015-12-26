"""This module accepts the name of a prefetched subreddit json dump
and loads and returns its contents as an object."""
import subreddit_dumps
import cPickle as pickle

def load(subreddit):
    f = open('subreddit_dumps/'+subreddit+'_dump.pkl', 'r')
    data = pickle.load(f)
    return data
