# Datamining Final project: Mining Reddit comments
The aim is to analyze and construct a data mining project using public Reddit comments from May 2015.The dataset can be found here https://www.kaggle.com/c/reddit-comments-may-2015.

The task is to study the dataset and prepare a proposal of what knowledge you plan to extract from this dataset using a data-minng technique. The proposal must then be implemented along with a report of the analysis, techniques, methodology, evaluation and results.

The approach here is to find communities within and across subreddits.

## Setup

You will first need to do the following

    git clone https://github.com/JherezTaylor/Datamining-Reddit.git 
    Download the dataset from the link above
    Move the database.sqlite file into redditComm/subreddit_dumps

### Extracting subreddit data

If you want to extract a given subreddit for use elsewhere then from within
the same folder do *python sqlextract.py* *subreddit_name* *output_format*. Currently
the argument accepts *json* or *pickle*. Any subreddit can be extracted. Output
goes to subreddit_dumps. Example *python sqlextract.py nba json*

### Running the entire config
    You need to be under Linux to run this, you can do it in Windows but that's torture
* You should have python pip already installed. Create a virtual environment by opening a terminal and doing *pip install virtualenv*
* Run redditComm/sqltojson.py with the argument being the name of the subreddit you want to extract. Ex: "python sqltojson.py nba"
* Move the generated json file to redditComm/subreddit_dumps
* Move the sqlite database to redditComm/subreddit_dumps
* Run the entire setup from within redditComm. "python run.py subreddit_name"
