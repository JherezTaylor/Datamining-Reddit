from modules import test
from modules import load_subreddit

def yo():
    test.heyBoy()
    with open('output/database_dump.json', 'w+') as f:
	       f.write("yoyo")
    f.closed
    load_subreddit.load()
if __name__ == '__main__':
    yo()
