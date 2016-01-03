import output, logging
import load_subreddit_castra, make_subreddit_castra
from dask.diagnostics import ProgressBar
from pprint import pprint
from time import time
import dask.dataframe as dd

logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging.getLogger('requests').setLevel(logging.CRITICAL)
logger = logging.getLogger(__name__)

# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def test(file_name):
    f = open('output/'+file_name+'.csv', 'w+')
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
    df_cfl = load_subreddit_castra.load('cfl')
    df_tennis = load_subreddit_castra.load('tennis')
    print df_cfl['ups'].count().compute()
    print df_tennis['ups'].count().compute()

    df_cfl = df_cfl[['author', 'link_id']].compute()
    df_tennis = df_tennis[['author', 'link_id']].compute()

    """
    If the categories aren't the same then you can't do a concat
    ie, the subreddit is a categorie and they hold different values
    for each dataframe
    http://pandas.pydata.org/pandas-docs/stable/categorical.html

    Because the field 'subreddit' is a category,
    both dataframes must have categories of the same type.
    Example, A = nba, B = hockey
    So A.subreddit = nba, B.subreddit = hockey

    They would have different values for subreddit so they can't be merged.
    To get around that I can drop the field subreddit from both then merge,
    but then it means that we would have to look up entries by the
    subreddit ID and not the actual name
    """
    # df2 = df_cfl.append(df_tennis, axis = 'columns', fill_value=None)
    # print df2.head()
    df2 = dd.concat([df_cfl, df_tennis], axis = 0, interleave_partitions=True)
    # print df2['link_id'].count().compute()
    print df2.head()
    df2.to_csv(f, header = True, encoding = 'utf-8')
    # print df2['ups'].count().compute()

    # print df2['ups'].count().compute()

    # bb_df = df[df.subreddit == 'baseball'].compute()
    # auth_per_top = df.groupby(['link_id', 'author'])['ups'].count().compute()
    # distinct_auth = auth_per_top.author.drop_duplicates().compute()
    # print auth_per_top.head(5)
    # df_two_weeks = df.loc['2015-05-01': '2015-05-07']
    # df_two_weeks_filter = df_two_weeks[['author', 'author_flair_text',
    #                                     'parent_id', 'link_id',
    #                                     'score', 'subreddit', 'id']].compute()
    #
    # df_two_weeks_filter.to_csv(f, header = True, encoding = 'utf-8')
    # print df_two_weeks.tail(2)
