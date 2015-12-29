#Using R to connect to the database and load librariees
library(RSQLite)
library(dplyr)
library(reshape2)
library(igraph)

reddit_db <- src_sqlite('database.sqlite', create = FALSE)

#STEP 1
#This code uses the dplyr package 
#https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html
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


#STEP 2: FILTERING THE DATA BY NUMBER OF AUTHORS ON EACH TOPIC 
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

relevant.frame <- tbl_df(data.frame(relevant.topics.by.authors)) # 2857 relevant topics

#STEP 3: FINDING THE TEAMS AND THE NUMBER OF AUTHORS WITHIN EACH TEAM. FILTERING BY AT LEAST 10 AUTHORS
#Number of teams in the subreddit
authors.in.team <- group_by(not.deleted.data, author_flair_text)
authors.in.team.sum <- summarise(authors.in.team, counting = n_distinct(author))
authors.valid.teams<- filter(authors.in.team.sum, counting >10) #over 10 because many teams only have 1, 2 or less than ten followers
authors.in.team.frame <- data.frame(authors.valid.teams)

#plotting the data for different teams
names <- authors.in.team.frame$author_flair_text
barplot(authors.in.team.frame$counting,legend=rownames(authors.in.team.frame$author_flair_text), beside="TRUE", names.arg=names,  col = "sky blue", cex.names=0.6, las=2)

#number of authors and teams
summarise(not.deleted.data, n_distinct(author_flair_text), n_distinct(author))


#STEP 4: CREATING A SUBSET OF THE DATA
#Just a try of the inner join... function only works with data frames
top.50 <- tbl_df(head(relevant.topics.by.authors,50))
test <- tbl_df(head(not.deleted.data,1000))
together <- inner_join(test,top.50) #works well and finds the topics that have more than one user

#Finding the teams for the authors in @together
teams <- distinct(select(together, author, author_flair_text))
teams.df <- tbl_df(teams)

summarise(together, n_distinct(author_flair_text), n_distinct(author))
#For subset:  flair_text = 36          no_authors = 192

#STEP 5: CREATE THE ADJACENCY MATRIX FOR THE GRAPH
non.deleted.authors <- filter(together, author!='[deleted]') #erase deleted authors.
authors.and.topics <- select(non.deleted.authors, author, link_id)

#trying to convert it into an adjacent matrix so that we can plot the graph
#http://web.stanford.edu/~messing/Affiliation%20Data.html
M = as.matrix(table(authors.and.topics)) # restructure your network data in matrix format
m = table(authors.and.topics)
M = as.matrix(m)
Mrow = M %*% t(M) #Mrow will be the one-mode matrix formed by the row entities. 2.7 Mb for 957 authors

#STEP 6: USING IGRAPH TO CONSTRUCT THE GRAPH
#http://jfaganuk.github.io/2015/01/02/analyzing-a-basic-network/

#graph.data <- graph.adjacency(Mrow, weighted = T, mode = 'directed')
#summary(graph.data) #192nodes #9360 edges

graph.data.order <- melt(Mrow, id.vars = c('author')) #Using graph.data.frame to reshape the matrix so that it is not wide, but tall
colnames(graph.data.order) <- c('source','target','weight') # changing the column names to a different format
graph.authors <- graph.data.frame(graph.data.order, directed = T) # make it into a graph data frame, the format for igraph
graph.authors <- simplify(graph.authors, remove.loops = T, remove.multiple = F)#removing self loops

#STEP 7: MATCHING THE TEAMS TO EACH OF THE NODES IN THE GRAPH
#code source: http://www.shizukalab.com/toolkits/sna/plotting-networks-pt-2
list.vertex.attributes(graph.authors) #this gets the attributes attached to the vertixes or nodes
V(graph.authors)$team=as.character(teams.df$author_flair_text[match(V(graph.authors)$name,teams.df$author)]) #matching teams with authors

#STEP 8: CREATING A SUBGRAPH WITH ELEMENTS THAT HAVE WEIGHT OVER 5 and PLOTTING
# filter the network based on weight over 5... if we leave vertices with edges<5 then it looks very messy
graph.authors.edge <- subgraph.edges(graph.authors, which(E(graph.authors)$weight >= 5))

tkplot(graph.authors.edge) #this makes an interactive plot out of the data

#network size
vcount(graph.authors.edge)
ecount(graph.authors.edge)
#Weight 5: 139 nodes / 712 eddges

#Plot graph 
plot.igraph(graph.authors.edge, layout=layout.fruchterman.reingold, vertex.size=7, vertex.label=NA, vertex.color="sky blue", edge.arrow.size=0.5, edge.color="blue", edge.label.font=5)
list.vertex.attributes(graph.authors.edge)

#STEP 9: FINDING COMMUNITIES

#First community algorithm: edge.betweenness.community
com <- edge.betweenness.community(graph.authors.edge, modularity=TRUE, merges=TRUE)
V(graph.authors.edge)$memb <- com$membership
modularity(com)

#Second community algorithm finds less communities
com2 <- walktrap.community(graph.authors.edge)
modularity(com2)
#plot the communities
plot(com2, graph.authors.edge, vertex.size=5, layout=layout.fruchterman.reingold, vertex.label=V(graph.authors.edge)$team, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)

#STEP 10: Centrality and Power Measures
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