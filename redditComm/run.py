from modules import user_pairings
from sys import argv

script, subreddit = argv

def process():
    # user_pairings.find(str(subreddit))
    user_pairings.test(subreddit)
if __name__ == '__main__':
    process()
