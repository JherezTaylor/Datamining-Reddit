import dask.dataframe as dd
import dask.bag as db
import subreddit_dumps, pprint, output
from dask.diagnostics import ProgressBar

# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def load(subreddit):
    # Load data into a dask dataframe:
    # df = dd.from_castra('./subreddit_dumps/'+subreddit+'_data.castra/')
    # print df.groupby(df.link_id).ups.mean().compute()
    # df.author.drop_duplicates().compute()
    # print df.author.head(4)
    # df.groupby(df.link_id).score.count().compute()
    # boy = df.groupby(df.link_id).score.count().compute()
    # boy = df.groupby([df.author]).compute()
    # comments_per_link = df.groupby([df.link_id,df.author]).ups.count().compute()
    hey = db.from_castra('./subreddit_dumps/'+subreddit+'_data.castra/')
    print hey
    # f = open('output/'+subreddit+'.', 'w+')
    # hey.to_csv(f)
    # f.closed
    # print comments_per_link
    # print comments_per_link
    # print comments_per_link.head(4)
    # print df.author.drop_duplicates().count().compute()
    # print user_list.head(4)
    # print df.head(4)
    # df._visualize()
    # print(df.ups.count().compute())
