#Using R to connect to the database
library(RSQLite)
library(dplyr)
library(data.table)

reddit_db <- src_sqlite('database.sqlite', create = FALSE)

#Getting the number of Subreddits
numSubred <-  tbl(reddit_db, sql("SELECT count(DISTINCT subreddit) FROM May2015"))

#Getting the nuber of subreddits in each category
top.subred <- tbl(reddit_db, sql("SELECT subreddit, count(subreddit) as numero FROM May2015 GROUP BY subreddit"))
top.subred.sum <- data.frame(top.subred)

#get the top data for the subreddits
table.top <- data.table(top.subred.sum)
mostViewed <- table.top[,.SD[order(numero,decreasing=TRUE)[1:20]]]
mostViewed

#plotting the number top 20 most used subreddits
names <- mostViewed$subreddit
barplot(mostViewed$numero, legend=rownames(mostViewed$subreddit), beside="TRUE", names.arg=names, col = "sky blue", cex.names=0.8, las=2)
