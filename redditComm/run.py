from modules import test

def yo():
    test.heyBoy()
    with open('output/database_dump.json', 'w+') as f:
	       f.write("yoyo")
    f.closed
if __name__ == '__main__':
    yo()
