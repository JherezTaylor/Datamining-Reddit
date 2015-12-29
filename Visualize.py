import sqlite3
import pandas as sql
import collections
import matplotlib.pyplot as plt


##importing the SQL file
con = sqlite3.connect( 'database.sqlite')

# Getting full table
#Results =sql.read_sql("""SELECT *  FROM May2015 WHERE author !='[deleted]'and subreddit ='nfl' """,con)

# SQL query for selecting author , link_id and parent_id from a NFL subreddit ## selecting root comments
#Relation_tablel=sql.read_sql("""SELECT link_id, parent_id FROM May2015 WHERE author !='[deleted]'and subreddit ='nfl' """,con)

# SQL Query for selecting distinct link_id ie the topic in the NFL data subreddit
#Relation_tablel=sql.read_sql("""SELECT author , count(link_id) as id  FROM May2015 WHERE author !='[deleted]'and subreddit ='baseball'  group by author order by id desc""" ,con)


Relation_tablel=sql.read_sql("""SELECT link_id, count(author) as NumOfAuthors FROM May2015 WHERE author !='[deleted]'and subreddit ='nfl'  group by link_id order by NumOfAuthors desc""" ,con)

#print(Relation_tablel)
#Relation_tablel=sql.read_sql("""SELECT author_flair_css_class,COUNT(author) AS NumberOfAuthors FROM May2015 WHERE author !='[deleted]'and subreddit ='baseball' GROUP BY author_flair_css_class""",con)

Relation_tablel.to_csv("NFL_LINK_NUMOfAuthors.csv");


