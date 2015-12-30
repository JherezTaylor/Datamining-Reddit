import output, logging
import load_subreddit_castra, make_subreddit_castra
from dask.diagnostics import ProgressBar
from pprint import pprint
from time import time

logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging.getLogger('requests').setLevel(logging.CRITICAL)
logger = logging.getLogger(__name__)

# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def test(file_name):
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

    # authors_flair = df.groupby(['author_flair_text', 'author', 'link_id'])['ups'].count().compute()
    # print authors_flair.head(10)
    # authors_flair.to_csv(f, header = True, encoding = 'utf-8')
    ts = time()
    df = load_subreddit_castra.load(file_name)

    # bb_df = df[df.subreddit == 'baseball'].compute()
    auth_per_top = df.groupby(['link_id', 'author'])['ups'].count().compute()
    # distinct_auth = auth_per_top.author.drop_duplicates().compute()
    print auth_per_top.head(5)
