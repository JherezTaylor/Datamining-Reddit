#Load libraries
library(dplyr)

reddit_db <- src_sqlite('database.sqlite', create = FALSE)

#PREPROCESSING IN ORDER TO LEAVE ONLY THE MOST POPULAR COMMENTS, TOPICS, SUBTOPICS AND AUTHORS

#STEP 1: CONNECTING TO THE DATABASE and QUERING ONLY RELEVANT DATA FOR US
#https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html

baseball <- tbl(reddit_db, sql("SELECT * FROM May2015 WHERE subreddit='baseball'"))
data <- select(baseball, author, author_flair_text, parent_id, link_id, score, subreddit, id)
not.deleted.data <- as.data.frame(filter(data, author!='[deleted]', !is.na(score)), n=-1) #erase values tht are deleted...

#number of number of topics, subtopics and authors
summarize(not.deleted.data, links = n_distinct(link_id), authors = n_distinct(author), parents = n_distinct(parent_id), comments = n_distinct(id))
          # links authors parents comments
          #  3241   14027   56201   112211

#2.1. BY THE NUMBER OF TIMES THAT EACH USER COMMENT ON ANY TOPIC IN THE SUBREDDIT
#Here we can argue we are only interested in users who are very active in the subreddit, those over the mean
authors.comments <- group_by(not.deleted.data, author)
authors.comments.sum <- as.data.frame(summarise(authors.comments, comments = n_distinct(id)))

summary(authors.comments.sum$comments)
#Min.    1st Qu.  Median    Mean 3rd Qu.    Max. 
#1       1       2       8       6         730 
boxplot(authors.comments.sum$comments, horizontal = TRUE, col = "light green")

comments.m <- mean(authors.comments.sum$comments)
authors.comments.df <- as.data.frame(filter(authors.comments.sum, comments>comments.m)) #authors that comment over the mean
relevant.authors.by.comments <- inner_join(not.deleted.data, authors.comments.df)

#2.2. BY NUMBER OF AUTHORS BY NUMBER OF TOPICS THEY COMMENT ON
    #Reason: to take out users that are not very active in the subreddit, but commented on one topic
top.users <- group_by(relevant.authors.by.comments , link_id)
top.users.df <- as.data.frame(summarise(top.users, no_topics = n_distinct(author)))
    
    summary(top.users.df$no_topics)
    #Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    #1.00    3.00    7.00   17.18   20.00  250.00 

active.m <- mean(top.users.df$no_topics)
top.users.data <- as.data.frame(filter(top.users.df, no_topics>active.m))
active.users.data <-inner_join(relevant.authors.by.comments,top.users.data)

#2.3 FILTERING TOPICS - link_id - BY SCORE: this assumes that in total users must get over n for their link to be relevant
#Use the average score by topic assuming that below that number topics are not popular
by.score <- group_by(active.users.data, link_id)
by.score.sum <- as.data.frame(summarise(by.score, score_topic = sum(score)))

summary(by.score.sum$score_topic)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  30.0   206.5   425.0   770.1   918.5  8417.0 
boxplot(by.score.sum$score_topic, horizontal = TRUE, col = "yellow")

score.m <- mean(by.score.sum$score_topic)
by.score.frame <- as.data.frame(filter(by.score.sum, score_topic>score.m))

#Inner join to find all the relevant data at last
relevant.sub.topics <- inner_join(active.users.data,by.score.frame)

#2.4. BY NUMBER OF AUTHORS THAT DIRECTLY INTERACT IN PARENT ID
#well, we may argue that discussions among more than the median are more interesting
authors.in.topic <- group_by(relevant.sub.topics, parent_id)
authors.in.topic.sum <- summarise(authors.in.topic, counting = n_distinct(author))

    summary(authors.in.topic.sum$counting)
    #Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    #1.000   1.000   1.000   1.738   2.000 120.000  

authors.m <- mean(authors.in.topic.sum$counting)
authors.in.topic.frame <- as.data.frame(filter(authors.in.topic.sum, counting>authors.m))
    #Visualization
    boxplot(authors.in.topic.frame$counting, horizontal = TRUE, col = "orange")

relevant.authors.data <- inner_join(relevant.sub.topics,authors.in.topic.frame) #Inner join to find all topics with more than one author

#2.5 NOW FILTER BY THE POPULARITY OF EACH SUBTOPIC BASED ON ITS SCORE
interactions.score <- group_by(relevant.authors.data, parent_id)
interactions.score <- as.data.frame(summarise(interactions.score, total_sub = sum(score)))

summary(interactions.score$total_sub)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  -96.00    7.00   17.00   56.79   41.00 3538.00
boxplot(interactions.score$total_sub, horizontal = TRUE, col = "yellow")

score.sub.m <- mean(interactions.score$total_sub)
interactions.score.frame <- as.data.frame(filter(interactions.score, total_sub>score.sub.m ))

#Inner join to find all the relevant data at last
data <- inner_join(relevant.authors.data,interactions.score.frame)

#INITIAL RESULTS: MORE THAN 100,000
#AFTER 1ST PREPROCESSING: 23,512
#AFTER 2nd PREPROCESSING: 11,678

summarize(data, links = n_distinct(link_id), authors = n_distinct(author), parents = n_distinct(parent_id), ids = n_distinct(id))
# links authors parents   ids
#1   264    2411    1167 11678

#export data
write.table(data, file="data.csv", row.names=FALSE, sep=",")
