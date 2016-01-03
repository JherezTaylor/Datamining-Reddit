import dask.dataframe as dd
from castra import Castra
import dask.bag as db
import pprint, output
from dask.diagnostics import ProgressBar

# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def load(file_name):
    c = Castra(path = './subreddit_dumps/'+file_name+'.castra/')
    df = c.to_dask()
    return df
