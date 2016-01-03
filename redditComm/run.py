from modules import dask_operations
from sys import argv

script, file_name = argv

def process():
    dask_operations.test(file_name)
if __name__ == '__main__':
    process()
