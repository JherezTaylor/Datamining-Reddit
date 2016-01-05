library(dplyr)
library(reshape2)
library(igraph)

data <- read.csv(file="all_sports_1_week.csv",head=TRUE,sep=",")

#STEP 1: FINDING THE TEAMS AND THE NUMBER OF AUTHORS WITHIN EACH TEAM. 
authors.in.team <- group_by(data, subreddit)
authors.in.team.sum <- as.data.frame(summarise(authors.in.team, counting = n_distinct(author)))

    #plotting the data for different teams
    names <- authors.in.team.sum$subreddit
    barplot(authors.in.team.sum$counting,
            legend=rownames(authors.in.team.sum$subreddit),
            beside="TRUE", names.arg=names,  col = "sky blue", cex.names=0.6, las=2)

#Finding the teams for the authors in our data
teams <- distinct(select(data, author, author_flair_text))
teams.df <- tbl_df(teams) #this makes a data frame matching authors with their team

summarise(teams.df, n_distinct(author_flair_text), n_distinct(author))
#Total number of teams:  899 , Total number of authors: 5128

#STEP 2: FINDING THE TEAMS AND THE NUMBER OF AUTHORS WITHIN EACH TEAM. 
subreddit <- group_by(data, subreddit)
subreddit.sum <- as.data.frame(summarise(subreddit, counting = n_distinct(author)))

#plotting the data for different teams
names <- authors.in.team.sum$author_flair_text
barplot(authors.in.team.sum$counting,
        legend=rownames(authors.in.team.sum$author_flair_text),
        beside="TRUE", names.arg=names,  col = "sky blue", cex.names=0.6, las=2)

#Finding the teams for the authors in our data
teams <- distinct(select(data, author, author_flair_text, subreddit))
teams.df <- tbl_df(teams) #this makes a data frame matching authors with their team

summarise(teams.df, n_distinct(author_flair_text), n_distinct(author))
#Total number of teams:  899 , Total number of authors: 5128



#STEP 3: CREATE THE ADJACENCY MATRIX FOR THE GRAPH
authors.and.topics <- select(data, author, link_id) #with parent_id matrix is 5 million


#convert it into an adjacent matrix so that we can plot the graph
#http://web.stanford.edu/~messing/Affiliation%20Data.html
M = as.matrix(table(authors.and.topics)) # restructure your network data in matrix format
m = table(authors.and.topics)
M = as.matrix(m)
Mrow = M %*% t(M) #Mrow will be the one-mode matrix formed by the row entities. 110 MB

#STEP 3: USING IGRAPH TO CONSTRUCT THE GRAPH
#http://jfaganuk.github.io/2015/01/02/analyzing-a-basic-network/

graph.data.order <- melt(Mrow, id.vars = c('author')) #Using graph.data.frame to reshape the matrix so that it is not wide, but tall
colnames(graph.data.order) <- c('source','target','weight') # changing the column names to a different format
graph.authors <- graph.data.frame(graph.data.order, directed = F) # make it into a graph data frame, the format for igraph
graph.authors <- simplify(graph.authors, remove.loops = T, remove.multiple = T)#removing self loops

#STEP 4: MATCHING THE TEAMS TO EACH OF THE NODES IN THE GRAPH
#code source: http://www.shizukalab.com/toolkits/sna/plotting-networks-pt-2
list.vertex.attributes(graph.authors) #this gets the attributes attached to the vertixes or nodes
V(graph.authors)$team=as.character(teams.df$author_flair_text[match(V(graph.authors)$name,teams.df$author)]) #matching teams with authors

#STEP 5: CREATING A SUBGRAPH WITH ELEMENTS THAT HAVE WEIGHT OVER 5 and PLOTTING
# filter the network based on weight over 5... if we leave vertices with edges<5 then it looks very messy
graph.authors.edge <- subgraph.edges(graph.authors, which(E(graph.authors)$weight > 150))

plot.igraph(graph.authors.edge, layout=layout.fruchterman.reingold, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)
boxplot(E(graph.authors)$weight, horizontal=TRUE) #mean weight is six

#Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#0.00     0.00     0.00     6.26     0.00 34620.00 

#Original network size
vcount(graph.authors) # 3501 for soccer and baseball
ecount(graph.authors) #6126750 edges

V(graph.authors.edge)$subreddit=as.character(teams.df$subreddit[match(V(graph.authors.edge)$name, teams.df$author)]) #matching subreddits
graph.density(graph.authors.edge) * 100


#Subgraph
vcount(graph.authors.edge) # 2562 nodes
ecount(graph.authors.edge) #278066 edges
#Weight 5: 3034 nodes / 342205 edges
#Weight 10: 2562 nodes / 278066 edges
#Weight 3: 2315 nodes / 59779 edges
#Weight 4: 1468 nodes / 26480 edges
#Weight 5: 1108 nodes / 15342 edges

#First community algorithm: fast greedy algorithm
com <- fastgreedy.community(graph.authors.edge)
V(graph.authors.edge)$memb <- com$membership
modularity(com) #0.4374315

#layout.fruchterman.reingold
plot(com, graph.authors.edge, vertex.size=5, layout=layout.fruchterman.reingold, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)

#subgraph of the largest community
x <- which.max(sizes(com))
sub.com.graph <- induced.subgraph(graph.authors.edge, which(membership(com) == x))
teams.fast.greedy <- tbl_df(as.data.frame(get.vertex.attribute(sub.com.graph)))

vcount(sub.com.graph) #1785 nodes
ecount(sub.com.graph) #33090 edges

#plotting subgraph

plot.igraph(sub.com.graph, vertex.size=5, layout=layout.kamada.kawai, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)


#summary of teams
top.com <- group_by(teams.fast.greedy, team)
top.com.df <- as.data.frame(summarise(top.com, Members = n_distinct(name)))

#ordering by top teams 
top.teams.com <- arrange(top_n(top.com.df, 20), desc(Members))

#barplot
com.names <- top.teams.com$team
barplot(top.teams.com$Members,legend=rownames(top.teams.com$team), beside="TRUE", names.arg=com.names,  col = "orange", cex.names=0.6, las=2)


#subgraph of the smalles community
z <- which.min(sizes(com))
min.graph <- induced.subgraph(graph.authors.edge, which(membership(com) == z))
teams.fast.greedy.min <- tbl_df(as.data.frame(get.vertex.attribute(min.graph)))

vcount(min.graph) # 92
ecount(min.graph) #1322

#plotting subgraph

plot.igraph(sub.com.graph, vertex.size=5, layout=layout.kamada.kawai, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)


#summary of teams
min.com <- group_by(teams.fast.greedy.min, subreddit)
min.com.df <- as.data.frame(summarise(min.com, Members = n_distinct(name)))

#barplot
com.names <- min.com.df$subreddit
barplot(min.com.df$Members,legend=rownames(min.com.df$subreddit), beside="TRUE", names.arg=com.names,  col = "orange", cex.names=0.6, las=2)





#summary of subreddits 
top.s <- group_by(teams.fast.greedy, subreddit)
top.s.df <- as.data.frame(summarise(top.s, Members = n_distinct(name)))


#barplot
sub.names <- top.s.df$subreddit
barplot(top.s.df$Members,legend=rownames(top.s.df$subreddit), beside="TRUE", names.arg=sub.names,  col = "gray", cex.names=1, las=2)





#ALTERNATIVE: SPINGLASS ALGORITHM Finds 10 communities
com2 <- spinglass.community(graph.authors.edge)
V(graph.authors.edge)$memb <- com2$membership
modularity(com2) #0.06434645

#Algorithm produces 691 communities... it is very sparse
plot(com2, graph.authors.edge, vertex.size=5, layout=layout.fruchterman.reingold, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)

#with spinglass algorithm
y <- which.max(sizes(com2))
subg <- induced.subgraph(graph.authors.edge, which(membership(com2) == y))
teams.community <- tbl_df(as.data.frame(get.vertex.attribute(subg)))

#summary
top.com2 <- group_by(teams.community, team)
top.com2.df <- as.data.frame(summarise(top.com2, Members = n_distinct(name)))

#ordering for top 
top.teams.com2 <- top_n(top.com2.df, 10)

#plotting the data for different teams
names <- top.teams.com2$team
barplot(top.teams.com2$Members,legend=rownames(top.teams.com2$team), beside="TRUE", names.arg=names,  col = "gray", cex.names=0.6, las=2)

