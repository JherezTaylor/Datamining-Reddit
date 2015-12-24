# Datamining Final project: Mining Reddit comments
* Analyze and construct a data mining project using public Reddit comments from May 2015.The dataset can be found here https://www.kaggle.com/c/reddit-comments-may-2015
* The task is to study the dataset and prepare a proposal of what knowledge you plan to extract from this dataset using a data-minng technique. The proposal must then be implemented along with a report of the analysis, techniques, methodology, evaluation and results.

# Setup
* Run redditComm/sqltojson.py with the argument being the name of the subreddit you want to extract. Ex: "python sqltojson.py nba"
* Move the generated json file to redditComm/subreddit_dumps
* Move the sqlite database to redditComm/subreddit_dumps
* Run the entire setup from within redditComm. "python run.py"
