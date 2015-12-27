import dask.dataframe as dd
import subreddit_dumps
from dask.diagnostics import ProgressBar

# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def load(subreddit):
    # Load data into a dask dataframe:
    df = dd.from_castra('./subreddit_dumps/'+subreddit+'_data.castra/')
    df.head(3)
