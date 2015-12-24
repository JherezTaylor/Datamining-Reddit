import sqlite3
import pandas as pd
import numpy as np
import collections
import matplotlib.pyplot as plt

sql_conn = sqlite3.connect('../input/database.sqlite')
# Reading distinct pairs (Author,Topics) from hockey subreddit
Results = sql_conn.execute('Select DISTINCT Author, link_id From May2015 WHERE subreddit = "hockey" ORDER BY Author')
listAuthor = []

# creating the author field from each pair
for Author in Results:
    listAuthor.append(Author[1])
    
# Counting the number of topic commented for each authors
counterAuthor = collections.Counter(listAuthor)

# counting the number of author commenting x amount of topics
frequency = collections.Counter(counterAuthor.values())

#plotting the histogram
plt.bar(range(len(frequency)), frequency.values(), align="center")
plt.xticks(range(len(frequency)), list(frequency.keys()))
plt.xlabel('nber topic')
plt.ylabel('nber user')
plt.show()
plt.savefig('Histogram of the number of users commenting a number of topic)
