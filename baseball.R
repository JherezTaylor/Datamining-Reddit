#Using R to connect to the database
library(RSQLite)
library(dplyr)
library(reshape2)
library(igraph)

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
summarize(not.deleted.data, links = n_distinct(link_id), authors = n_distinct(author), parents = n_distinct(parent_id), ids = n_distinct(id), names = n_distinct(name))

#  links authors parents  ids    names
#  (int)   (int)   (int)
#  3242   14028   56315  112573  112573

#NUMBER OF AUTHORS THAT COMMENT EACH TOPIC 
authors.in.topic <- group_by(not.deleted.data, link_id)
authors.in.topic.sum <- summarise(authors.in.topic, counting = n_distinct(author))
relevant.topics.by.authors<- filter(authors.in.topic.sum, counting>1)
authors.in.topic.frame <- data.frame(relevant.topics.by.authors)

#stats
summary(authors.in.topic.frame$counting)
boxplot(authors.in.topic.frame$counting, horizontal = TRUE)


#Summary: Authors by topic (link_id)
#Min.    1st Qu.  Median    Mean    3rd Qu.    Max. 
#1.00    3.00     9.00      22.93   24.75      475.00 

#Number of teams in the subreddit
authors.in.team <- group_by(not.deleted.data, author_flair_text)
authors.in.team.sum <- summarise(authors.in.team, counting = n_distinct(author))
authors.valid.teams<- filter(authors.in.team.sum, counting >10) #over 10 because many teams only have 1, 2 or less than ten followers
authors.in.team.frame <- data.frame(authors.valid.teams)

#plotting the data for different teams
names <- authors.in.team.frame$author_flair_text
barplot(authors.in.team.frame$counting,legend=rownames(authors.in.team.frame$author_flair_text), beside="TRUE", names.arg=names,  col = "sky blue", cex.names=0.6, las=2)

#use only the posts that have more than one author so we can actually see interaction... 
#a. frame to try some things
relevant.frame <- tbl_df(data.frame(relevant.topics.by.authors)) # 2857 relevant topics

summarise(not.deleted.data, n_distinct(author_flair_text), n_distinct(author))
#  flair_text = 50          no_authors = 586

#c. Just a try of the inner join... function only works with data frames
top.50 <- tbl_df(head(relevant.topics.by.authors,50))
test <- tbl_df(head(not.deleted.data,1000))
together <- inner_join(test,relevant.frame) #works well and finds the topics that have more than one user

summarise(together, n_distinct(author_flair_text), n_distinct(author))
#For subset:  flair_text = 50          no_authors = 586

#CORE: Now I need a list of authors by topic
non.deleted.authors <- filter(together, author!='[deleted]') #erase deleted authors.
authors.and.topics <- select(non.deleted.authors, author, link_id)

summarise(together, n_distinct(author)) 

#trying to convert it into an adjacent matrix so that we can plot the graph
#http://web.stanford.edu/~messing/Affiliation%20Data.html
M = as.matrix(table(authors.and.topics)) # restructure your network data in matrix format
m = table(authors.and.topics)
M = as.matrix(m)
Mrow = M %*% t(M) #Mrow will be the one-mode matrix formed by the row entities. 2.7 Mb for 957 authors

#Now using igraph
#http://jfaganuk.github.io/2015/01/02/analyzing-a-basic-network/

graph.data <- graph.adjacency(Mrow, weighted = T, mode = 'directed')
summary(graph.data) #585 nodes #25281 edges

#Using graph.data.frame to reshape the matrix so that it is not wide, but tall
graph.data.order <- melt(Mrow, id.vars = c('author'))

# changing the column names to a different format
colnames(graph.data.order) <- c('source','target','weight')

# make it into a graph data frame, the format for igraph
graph.authors <- graph.data.frame(graph.data.order, directed = T)

#removing self loops
graph.authors <- simplify(graph.authors, remove.loops = T, remove.multiple = F)

tkplot(graph.authors.edge) #this makes an interactive plot out of the data

# filter the network based on weight over 5... if we leave vertices with edges<5 then it looks very messy
graph.authors.edge <- subgraph.edges(graph.authors, which(E(graph.authors)$weight >= 5))

#network size
vcount(graph.authors.edge)
ecount(graph.authors.edge)
#Weight 1: 581 nodes / 24696 edges
#Weight 2: 530 nodes / 8372 edges
#Weight 3: 413 nodes / 3578 eddges
#Weight 4: 364 nodes / 2556 eddges
#Weight 5: 334 nodes / 1316 eddges

#Plot 1
plot.igraph(graph.authors.edge, layout=layout.fruchterman.reingold, vertex.size=7, vertex.label=NA, vertex.color="sky blue", edge.arrow.size=0.5, edge.color="blue", edge.label.font=5)

#RESULT: Finding communities
com <- edge.betweenness.community(graph.authors.edge, modularity=TRUE, merges=TRUE)
V(graph.authors.edge)$memb <- com$membership
modularity(com)

#Centrality and Power Measures
#Degree
degree(graph.authors.edge)
degree(graph.authors.edge, mode = 'total')
degree(graph.authors.edge, mode = 'in')
degree(graph.authors.edge, mode = 'out')

#Betweennes
betweenness(graph.authors.edge)

#closeness
closeness(graph.authors.edge1)

# extract the components
g.components <- clusters(graph.authors.edge)

# which is the largest component
ix <- which.max(g.components$csize)

#export data for gephi
write.table(g2, file="data.csv", row.names=FALSE, sep=",")