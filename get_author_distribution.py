import csv, sys
import sqlite3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
results = []
count = 0
main_loop = 0

# Function checkGeoData definiiton 
#This function is responsible to check venues latitude and longitude information
# If data exist in Semnatics file then create new record in output file with latitude, longitude and semantics
def getAuthDist(auth):
	with open('authors_distibution.csv', 'ab') as auth_dist:
		sql_conn = sqlite3.connect('F:/ACADEMICS/TIGP-SNHCC/3rd-Term/Data Mining/Term Project/database/database.sqlite')
		c = sql_conn.cursor()
		#print auth;
		placeholder= '?' # For SQLite. See DBAPI paramstyle.
		placeholders= ', '.join(placeholder for unused in auth)
		#query_authors="SELECT author, subreddit, count(id) as posts FROM May2015 WHERE author =? GROUP BY subreddit ORDER BY posts desc" % placeholders
		c.execute('SELECT author, subreddit, count(id) as posts FROM May2015 WHERE author =? GROUP BY subreddit ORDER BY posts desc', (auth,))
		#df = c.execute(query_authors, auth)
		all_rows = c.fetchall()
		sql_conn.close()

		for row in all_rows:			
			author = row[0]
			subred = row[1]
			posts = row[2]

			#print 'Author', author , ', Subreddit', subred , ', Number of Posts', posts
			# Write data to CSV files
			writer.writerow({'author': author, 'subreddit': subred, 'posts': posts})			
		
		return True			


with open('top_authors.csv', 'r') as top_authors, open('authors_distibution.csv', 'ab') as auth_dist:
	#Create new file to merge data of Venues and Semantics
	fieldnames = ['author', 'subreddit', 'posts']
	writer = csv.DictWriter(auth_dist, fieldnames=fieldnames)
	writer.writeheader()
	#Read data from authors file and get authors distibution by subreddit
	reader = csv.reader(top_authors)
	reader.next()
	main_loop = 0
	for authors in reader:
		author_name = authors[1]
		author_total_distribution = authors[2]		
		print "Main Loop=" , main_loop
		main_loop = main_loop + 1
		# Call Authors Distribution function and write authors posts in a CSV file
		getAuthDist(author_name)
