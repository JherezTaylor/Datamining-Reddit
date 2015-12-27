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

#CORE: Now I need a list of authors by topic
non.deleted.authors <- filter(together, author!='[deleted]') #erase deleted authors.
authors.and.topics <- select(non.deleted.authors, author, link_id)

#trying to convert it into a matrix
#http://web.stanford.edu/~messing/Affiliation%20Data.html
M = as.matrix(table(authors.and.topics)) # restructure your network data in matrix format
m = table(authors.and.topics)
M = as.matrix(m)
Mrow = M %*% t(M) #Mrow will be the one-mode matrix formed by the row entities. 2.7 Mb for 957 authors

head(Mrow)
#Now using igraph
#http://jfaganuk.github.io/2015/01/02/analyzing-a-basic-network/

library(igraph)
g1 <- graph.adjacency(Mrow, weighted = T, mode = 'directed')
summary(g1) #585 nodes #25281 edges

#Using graph.data.frame to reshape the matrix so that it is not wide, but tall
library(reshape2)
g2 <- melt(Mrow, id.vars = c('author'))

# changing the column names
colnames(g2) <- c('source','target','weight')

# we also need to trim the names
g <- graph.data.frame(g2, directed = T)

#removing self loops
g <- simplify(g, remove.loops = T, remove.multiple = F)

# filter the network based on weight
g.edge3 <- subgraph.edges(g, which(E(g)$weight < 4))
g1.edge3 <- subgraph.edges(g.edge3, which(E(g.edge3)$weight == 1))

#Centrality and Power Measures

#Degree
degree(g1.edge3)
degree(g1.edge3, mode = 'total')
degree(g1.edge3, mode = 'in')
degree(g1.edge3, mode = 'out')

#Betweennes
betweenness(g1.edge3)

#closeness
closeness(g1.edge3)

#network size
vcount(g1.edge3)
ecount(g1.edge3)

# extract the components
g.components <- clusters(g)

# which is the largest component
ix <- which.max(g.components$csize)

#finding communities
com <- edge.betweenness.community(g1.edge3)
V(g1.edge3)$memb <- com$membership
modularity(com)

plot(com, g1.edge3)
