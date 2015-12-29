# Datamining Final project: Mining Reddit comments
The aim is to analyze and construct a data mining project using public Reddit
comments from May 2015.The dataset can be found
[here].(https://www.kaggle.com/c/reddit-comments-may-2015.)

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

### Extracting the subreddit data

To extract and convert the entire dataset to a castra file

You will need to do the following

    pyhton extract_fulldb.py

If you want to extract a given subreddit for use elsewhere then from within
the redditComm do

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

    python run.py *subreddit_name*
