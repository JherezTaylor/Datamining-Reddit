from modules import find_communities
from sys import argv

script, file_name = argv

def process():
    # user_pairings.find(str(subreddit))
    find_communities.test(file_name)
if __name__ == '__main__':
    process()
