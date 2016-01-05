#Load libraries
library(dplyr)

reddit_db <- src_sqlite('database.sqlite', create = FALSE)

#PREPROCESSING IN ORDER TO LEAVE ONLY THE MOST POPULAR COMMENTS, TOPICS, SUBTOPICS AND AUTHORS
#STEP 1: CONNECTING TO THE DATABASE and QUERING ONLY RELEVANT DATA FOR US
#https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html...........

all_data <- tbl(reddit_db, sql("SELECT * FROM May2015"))
dataset<- filter(all_data, subreddit == 'baseball' | subreddit == 'soccer' | subreddit == 'hockey'|subreddit == 'nfl'| subreddit == 'nba')
clean.dataset <- filter(dataset, author!='[deleted]', !is.na(score))
head(clean.dataset)

data.select <- select(clean.dataset, created_utc, author, subreddit, author_flair_text, parent_id, link_id, score, subreddit, id)
data <- as.data.frame(filter(data.select, author!='[deleted]'), n=-1) #erase values tht are deleted...

#data <- read.csv(file="all_data.csv",head=TRUE,sep=",")

#Decided to export data to save memory
write.table(data, file="all_data_five_sports.csv", row.names=FALSE, sep=",")

#Summary of data for all sports... left out sports that do not have a lot of users like Olympics
summarize(data, links = n_distinct(link_id), authors = n_distinct(author), parents = n_distinct(parent_id), comments = n_distinct(id), deportes = n_distinct(subreddit))
          # TOPICS   authors parents  comments sports
          # 33752  140703 1003402  2282166        5


#2.0. BY THE NUMBER OF TIMES THAT EACH USER COMMENTs ON THE SUBREDDITS
#Here we are filtering only by the number of users who comment accross subreddit, 0 will be deleted
by.subreddit <- group_by(data, author)
by.subreddit.sum <- as.data.frame(summarise(by.subreddit, No_subreddits = n_distinct(subreddit)))

summary(by.subreddit.sum$No_subreddits)
#Min.    1st Qu.  Median    Mean    3rd Qu.    Max. 
#1.000   1.000    1.000     1.214   1.000      10.000 
boxplot(by.subreddit.sum$No_subreddits, horizontal = TRUE, col = "light green")

subreddit.m <- mean(by.subreddit.sum$No_subreddits)
subreddit.df <- as.data.frame(filter(by.subreddit.sum, No_subreddits>subreddit.m)) #authors that comment over the mean
relevant.by.subreddit <- inner_join(data, subreddit.df)

#2.1. BY THE NUMBER OF TIMES THAT EACH USER COMMENT ON ANY TOPIC IN THE SUBREDDIT
#Here we can argue we are only interested in users who are very active in the subreddit, those over the mean
authors.comments <- group_by(relevant.by.subreddit, author)
authors.comments.sum <- as.data.frame(summarise(authors.comments, comments = n_distinct(id)))

summary(authors.comments.sum$comments)
#Min.    1st Qu.  Median    Mean 3rd Qu.    Max. 
#2.00     5.00    12.00    43.92    35.00 86200.00
boxplot(authors.comments.sum$comments, horizontal = TRUE, col = "light green")

comments.m <- mean(authors.comments.sum$comments)
authors.comments.df <- as.data.frame(filter(authors.comments.sum, comments>comments.m)) #authors that comment over the mean
relevant.authors.by.comments <- inner_join(relevant.by.subreddit, authors.comments.df)

#2.2. BY NUMBER OF AUTHORS BY NUMBER OF TOPICS THEY COMMENT ON
    #Reason: to take out users that are not very active in the subreddit, but commented on one topic
top.users <- group_by(relevant.authors.by.comments , link_id)
top.users.df <- as.data.frame(summarise(top.users, no_topics = n_distinct(author)))
    
    summary(top.users.df$no_topics)
    #Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    #1.00    1.00    4.00   11.15   10.00  860.00 

active.m <- mean(top.users.df$no_topics)
top.users.data <- as.data.frame(filter(top.users.df, no_topics>active.m))
active.users.data <-inner_join(relevant.authors.by.comments,top.users.data)

#2.3 FILTERING TOPICS - link_id - BY SCORE: this assumes that in total users must get over n for their link to be relevant
#Use the average score by topic assuming that below that number topics are not popular
by.score <- group_by(active.users.data, link_id)
by.score.sum <- as.data.frame(summarise(by.score, score_topic = sum(score)))

summary(by.score.sum$score_topic)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  -1371.0   113.0   259.0   780.3   705.0 39110.0 
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
    #1.000   1.000   1.000   1.507   1.000 516.000  

authors.m <- mean(authors.in.topic.sum$counting)
authors.in.topic.frame <- as.data.frame(filter(authors.in.topic.sum, counting>authors.m))
    #Visualization
    boxplot(authors.in.topic.frame$counting, horizontal = TRUE, col = "orange")

relevant.authors.data <- inner_join(relevant.sub.topics,authors.in.topic.frame) #Inner join to find all topics with more than one author
subreddits.data <- filter(relevant.authors.data, author!='[deleted]')


#2.5 NOW FILTER BY THE POPULARITY OF EACH SUBTOPIC BASED ON ITS SCORE
interactions.score <- group_by(subreddits.data, parent_id)
interactions.score <- as.data.frame(summarise(interactions.score, total_sub = sum(score)))

summary(interactions.score$total_sub)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   -208.00     3.00     9.00    74.99    35.00 12920.00
boxplot(interactions.score$total_sub, horizontal = TRUE, col = "yellow")

score.sub.m <- mean(interactions.score$total_sub)
interactions.score.frame <- as.data.frame(filter(interactions.score, total_sub>score.sub.m ))

#Inner join to find all the relevant data at last
preprocessed.data <- inner_join(subreddits.data,interactions.score.frame)

#RESULTS OF PREPROCESSING:
summarize(preprocessed.data, links = n_distinct(link_id), authors = n_distinct(author), parents = n_distinct(parent_id), ids = n_distinct(id))
#links authors parents    ids
#1444    4375    6004   148619

#export data
write.table(preprocessed.data, file="data_all_sports.csv", row.names=FALSE, sep=",")
