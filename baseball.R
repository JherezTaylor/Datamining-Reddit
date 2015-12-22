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

#NUMBER OF AUTHORS THAT COMMENT EACH TOPIC 
authors.in.topic <- group_by(not.deleted.data, link_id)
authors.in.topic.sum <- summarise(authors.in.topic, counting = n_distinct(author))
authors.in.topic.frame <- data.frame(authors.in.topic.sum)

#stats
summary(authors.in.topic.frame$counting)
boxplot(authors.in.topic.frame$counting, horizontal = TRUE)

#Summary: Authors by topic (link_id)
#Min.    1st Qu.  Median    Mean    3rd Qu.    Max. 
#1.00    3.00     9.00      22.93   24.75      475.00 

#use only the posts that have more than one author so we can actually see interaction... 
#a. frame to try some things
relevant.frame <- tbl_df(data.frame(relevant.topics.by.authors)) # 2857 relevant topics

#b. Select query on relevant attributes only
all.posts <- select(not.deleted.data, created_utc, subreddit, link_id, name, author, score, body, controversiality)
all.posts.sum <- summarise(all.posts, nm = n()) #112573

#c. Just a try of the inner join... function only works with data frames
top.50 <- tbl_df(head(relevant.topics.by.authors,50))
test <- tbl_df(head(not.deleted.data,1000))
together <- inner_join(test,relevant.frame) #works well and finds the topics that have more than one user
