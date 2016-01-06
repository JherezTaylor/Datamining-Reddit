# Datamining Final project: Mining Reddit comments
The aim is to analyze and construct a data mining project using public Reddit
comments from May 2015.The dataset can be found
[here.](https://www.kaggle.com/c/reddit-comments-may-2015)

The task is to study the dataset and prepare a proposal of what knowledge you
plan to extract from this dataset using a data-minng technique.
The proposal must then be implemented along with a report of the analysis,
techniques, methodology, evaluation and results.

The approach here is to find communities within and across subreddits.

## Setup

You will first need to do the following

    git clone https://github.com/JherezTaylor/Datamining-Reddit.git
    Download the dataset from the link above
    Create a folder redditComm/subreddit_dumps and move database.sqlite there
    Create a folder redditComm/subreddit_dumps/json

### Extracting the subreddit data

To extract and convert the entire dataset to a castra file

You will need to do the following. **Warning** This will generation 20+GB of
files to redditComm/subreddit_dumps/json
Each file is a json object of an entire subreddit. It is hacky
but it is necessary to first extract the entire sqlite db, merge the subreddits
into one file then convert it to a castra. The reason for this is that the db
can't fit in memory (unless you have 30GB of ram lying around) and so it's not
possible to extract it all in one query. It's implemented using the
multiprocessing module from python.

Now, the query will hang at 36,025 out of 50,138 subreddits. Not sure exactly
why this happens but the entire process takes a few hours before it hangs,
always at the same subreddit 'zzzz' and the same number of files, 36,025. So
guess what? More hacky workarounds. The script accepts the list of subreddits as
an argument, just the name of the file without the extension. On the first run
call the script from redditComm/utils

    python extract_fulldb.py subreddit_list

Go drink some coffee and read a book. When the script hangs, close the terminal
and then from the same folder as before run:

    python salvage_extract.py

This will look in the folder where we are dumping the subreddits, check the
contents and compares it the master list of subreddits to see what's missing.
It generates a new json list for us to continue from. Now go and run the extract
again, this time passing the newly generated file as the argument. Both these
files are in the repo so you don't need to run the salvage module but it's there
redditComm/utils if you need it.

    python extract_fulldb.py unprocessed_list

*Update* It fails a few times, there might be an issue with the multiprocessing
pool running into some overhead somewhere. Run extract again if it fails and repeat
the process above.

You can delete the files in redditComm/subreddit_dumps/json
and the merged json file when the script completes.

If you want to extract a given subreddit for use elsewhere then from within
the redditComm/utils do

    python extract_subreddit.py subreddit_name output_format

Currently the argument accepts *json* or *pickle* and any subreddit can be
extracted. Output goes to

    redditComm/subreddit_dumps
Example

    python extract_subreddit.py nba json

### Running the entire project
You need to be under Linux to run this, you can do it in Windows but setting
up the required packages won't be covered here.

You should have python pip already installed. Create a virtual environment by
opening a terminal and doing

    pip install virtualenv
    cd redditComm
    virtualenv venv

To begin using the virtual environment, it needs to be activated

    source venv/bin/activate

#### Install the requirements
Before you install requirements.txt you may need to do

    sudo apt-get install libpng-dev libfreetype6-dev graphviz libhdf5-dev libatlas-base-dev gfortran

Then

    cd .. *up to the root folder of the repo*
    pip install -r requirements.txt
    You may need to do pip install dask[complete]

Okay so we should be good to go. Create your scripts and add them to
redditComm/modules. Follow the structure of the existing files. Import modules
to *run.py*, create a method and load a function of your module there. Call the
created method to run at start.

Run with

    python run.py
