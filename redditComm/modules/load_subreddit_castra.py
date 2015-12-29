import dask.dataframe as dd
from castra import Castra
import dask.bag as db
import subreddit_dumps, pprint, output
from dask.diagnostics import ProgressBar
import json
# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def load(subreddit):
    f = open('output/'+subreddit+'.csv', 'w+')
    c = Castra(path = './subreddit_dumps/'+subreddit+'_data.castra/')
    df = c.to_dask()

    # Subsetting the dataframe
    # a = df[df.link_id == 't3_36k7u4'].compute()

    # Get multiple columns from the dataframe
    # b = df[['author', 'subreddit']].compute()

    # Groupby operations
    # c = df.groupby(['link_id', 'author'])['ups'].count().compute()
    # c = df.groupby(df.link_id).ups.mean().compute()
    # c = df.groupby(df.link_id).score.count().compute()

    # Drop duplicates
    # d = df.author.drop_duplicates().compute()

    # Column access
    # d = df.author.head(4) // First 4 authors
    # df.ups[df.ups > 7].compute()

    # Selections
    # len(df[df.amount > 0])

    # comments_per_link_by_author = df.groupby(['link_id', 'author'])['ups'].count().compute()
    # comments_per_link_by_author.to_csv(f, header = True)

    authors_flair = df.groupby(['author_flair_text', 'author', 'link_id'])['ups'].count().compute()
    print authors_flair.head(10)
    authors_flair.to_csv(f, header = True, encoding = 'utf-8')
