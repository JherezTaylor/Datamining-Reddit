import dask.dataframe as dd
import subreddit_dumps, pprint
from dask.diagnostics import ProgressBar

# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def load(subreddit):
    # Load data into a dask dataframe:
    df = dd.from_castra('./subreddit_dumps/'+subreddit+'_data.castra/')
    print df.groupby(df.link_id).ups.mean().compute()
    df.author.drop_duplicates().compute()
    # print df.author.head(4)
    print df.author.drop_duplicates().count().compute()
    # print user_list.head(4)
    # print df.head(4)
    # df._visualize()
    # print(df.ups.count().compute())
