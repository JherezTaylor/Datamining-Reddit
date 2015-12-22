#Using R to connect to the database
library(RSQLite)
library(dplyr)
library(data.table)

reddit_db <- src_sqlite('database.sqlite', create = FALSE)

#Using only TBL package
baseball <- tbl(reddit_db, sql("SELECT * FROM May2015 WHERE subreddit='baseball'"))
not.deleted.data <- filter(baseball, body!='[deleted]', !is.na(score)) #erase values tht are deleted...

#summary of statistics
summarise(not.deleted.data, mean_score = mean(score), median_score = median(score), sd_score= sd(score), max_score = max(score), total_comments = n())
#mean_score        median_score sd_score max_score
#     (dbl)        (int)    (dbl)     (int)  total_comments
#    8.500227      3       22.57579   1652  112,573

#number of number of topics, subtopics and authors
summarize(not.deleted.data, links = n_distinct(link_id), authors = n_distinct(author), parents = n_distinct(parent_id))

#  links authors parents
#  (int)   (int)   (int)
#  3242   14028   56315