import output, logging
import load_subreddit_castra, make_subreddit_castra
from dask.diagnostics import ProgressBar
from pprint import pprint
import pandas as pd
import dask.dataframe as dd

logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging.getLogger('requests').setLevel(logging.CRITICAL)
logger = logging.getLogger(__name__)

# Start a progress bar for all computations
pbar = ProgressBar()
pbar.register()

def test(file_name):
    """
    # Subsetting the dataframe
    a = df[df.link_id == 't3_36k7u4'].compute()

    # Get multiple columns from the dataframe
    b = df[['author', 'subreddit']].compute()

    # Groupby operations
    c = df.groupby(['link_id', 'author'])['ups'].count().compute()
    c = df.groupby(df.link_id).ups.mean().compute()
    c = df.groupby(df.link_id).score.count().compute()

    # Drop duplicates
    d = df.author.drop_duplicates().compute()

    # Column access
    d = df.author.head(4) // First 4 authors
    df.ups[df.ups > 7].compute()

    # Drop Column
    df.drop('reports', axis=1)
    # Selections
    len(df[df.amount > 0])
    comments_per_link_by_author = df.groupby(['link_id', 'author'])['ups'].count().compute()
    comments_per_link_by_author.to_csv(f, header = True)
    authors_flair = df.groupby(['author_flair_text', 'author', 'link_id'])['ups'].count().compute()

    # Disk writes
    f = open('output/'+file_name+'.csv', 'w+')
    authors_flair.to_csv(f, header = True, encoding = 'utf-8')
    df.set_index('timestamp', compute=False).to_castra('myfile.castra', categories=True)
    """

    """
    If the categories aren't the same then you can't do a concat
    ie, the subreddit is a categories and they hold different values
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

    # print authors_flair.head(10)
    f = open('output/'+file_name+'.csv', 'w+')
    # df_baseball = load_subreddit_castra.load('baseball')
    df = pd.read_csv('output/data_all_sports.csv', header=1,
                    index_col='created_utc', names=['created_utc', 'author',
                    'subreddit', 'authors_flair_text',
                    'parent_id', 'link_id', 'score', 'id',
                    'No_subreddits', 'comments', 'no_topics', 'score_topic',
                    'counting', 'total_sub'])
    # df2 = df.set_partition('created_utc', divisions=[10, 20, 50])
    print df.head()
    df_two_weeks = df.loc[1430438400:1430999999]
    # slice('1913','1914'
    # df_two_weeks.to_csv(f, header = True, encoding = 'utf-8')

    # df_tennis = load_subreddit_castra.load('tennis')

    # Drop categoricals for concat operations
    # Axis 1 indicates that we are referring to columns and not rows
    # df_cfl = df_cfl.drop(['distinguished', 'removal_reason'], axis = 1)
    # df_tennis = df_tennis.drop(['distinguished', 'removal_reason'], axis = 1)

    # df_baseball = df_baseball.drop(['distinguished', 'removal_reason'], axis = 1)
    # print df_cfl['ups'].count().compute()
    # print df_tennis['ups'].count().compute()

    # df_baseball = df_baseball.dropna(subset = ['body', 'author', 'score'], how = 'any')
    # # print df_baseball.describe()
    # # df_baseball.author.drop_duplicates().compute()
    # df2 = df_baseball.link_id.drop_duplicates().compute()
    # df2.to_csv(f, header = True, encoding = 'utf-8')
    # df_baseball.parent_id.drop_duplicates().compute()
    # df_baseball.id.drop_duplicates().compute()
    # print df_baseball['link_id'].count().compute()
    # df_baseball_unique.parent_id.drop_duplicates().compute()
    # df_baseball_unique.link_id.drop_duplicates().compute()
    # df_baseball_unique.id.drop_duplicates().compute()
    #
    # df_baseball_unique['author'].count().compute()
    # df_baseball_unique['link_id'].count().compute()
    # df_baseball_unique['id'].count().compute()
    # df_baseball_unique['parent_id'].count().compute()
    # print df_cfl['ups'].count().compute()
    # df_cfl.to_csv(f, header = True, encoding = 'utf-8')

    # Axis 0 indicates that we want a vertical concat
    # df2 = dd.concat([df_cfl, df_tennis], axis = 0, interleave_partitions=True)
    # print df2['link_id'].count().compute()
    # # print df2.head()
    # df2.to_csv(f, header = True, encoding = 'utf-8')

    # df_cfl = df_cfl[['author', 'link_id']].compute()
    # df_tennis = df_tennis[['author', 'link_id']].compute()


    # df2 = df_cfl.append(df_tennis, axis = 'columns', fill_value=None)
    # print df2.head()
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
