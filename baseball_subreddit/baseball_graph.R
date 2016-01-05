library(dplyr)
library(reshape2)
library(igraph)

data <- read.csv(file="baseball_data.csv",head=TRUE,sep=",")

#STEP 1: FINDING THE TEAMS AND THE NUMBER OF AUTHORS WITHIN EACH TEAM. 
authors.in.team <- group_by(data, author_flair_text)
authors.in.team.sum <- as.data.frame(summarise(authors.in.team, counting = n_distinct(author)))

    #plotting the data for different teams
    names <- authors.in.team.sum$author_flair_text
    barplot(authors.in.team.sum$counting,
            legend=rownames(authors.in.team.sum$author_flair_text),
            beside="TRUE", names.arg=names,  col = "sky blue", cex.names=0.6, las=2)

#Finding the teams for the authors in our data
teams <- distinct(select(data, author, author_flair_text))
teams.df <- tbl_df(teams) #this makes a data frame matching authors with their team

summarise(teams.df, n_distinct(author_flair_text), n_distinct(author))
#Originally: Total number of teams: 103  , Total number of authors: 12500
#After preprocessing: Total number of teams:  76 , Total number of authors:  2685

#STEP 2: CREATE THE ADJACENCY MATRIX FOR THE GRAPH
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
graph.authors.edge <- subgraph.edges(graph.authors, which(E(graph.authors)$weight >= 3))

#Original network size
vcount(graph.authors)
ecount(graph.authors)
# 2685 nodes / 3,603,270 edges...

#Subgraph
vcount(graph.authors.edge)
ecount(graph.authors.edge)
#Weight 5:  2537 nodes /82784 edges
graph.density(graph.authors.edge) * 100


plot.igraph(graph.authors.edge, vertex.size=5, layout=layout.kamada.kawai, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)
#First community algorithm: fast greedy algorithm
com <- fastgreedy.community(graph.authors.edge)
V(graph.authors.edge)$memb <- com$membership
modularity(com) #0.3852977

plot(com, graph.authors.edge, vertex.size=5, layout=layout.fruchterman.reingold, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)

#subgraph of the largest community
x <- which.max(sizes(com))
sub.com.graph <- induced.subgraph(graph.authors.edge, which(membership(com) == x))
teams.fast.greedy <- tbl_df(as.data.frame(get.vertex.attribute(sub.com.graph)))

vcount(sub.com.graph) #1583 nodes
ecount(sub.com.graph) #36022 edges

#plotting subgraph
plot.igraph(sub.com.graph, vertex.size=5, layout=layout.fruchterman.reingold, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)

# Converts the given igraph object to GEXF format and saves it at the given filepath location
#     g: input igraph object to be converted to gexf format
#     filepath: file location where the output gexf file should be saved
source("iGraph_GexF_Exporter.R")
saveAsGEXF(sub.com.graph, "community_baseball.gexf")



#summary
top.com <- group_by(teams.fast.greedy, team)
top.com.df <- as.data.frame(summarise(top.com, Members = n_distinct(name)))

#ordering by top teams 
top.teams.com <- arrange(top_n(top.com.df, 10), desc(Members))

#barplot
com.names <- top.teams.com$team
barplot(top.teams.com$Members,legend=rownames(top.teams.com$team), beside="TRUE", names.arg=com.names,  col = "dark gray", cex.names=0.6, las=2)



#subgraph of the smallest community
z <- which.min(sizes(com))
sub.com.graph.2 <- induced.subgraph(graph.authors.edge, which(membership(com) == z))
teams.fast.greedy.min <- tbl_df(as.data.frame(get.vertex.attribute(sub.com.graph.2)))


vcount(sub.com.graph.2) #63 nodes
ecount(sub.com.graph.2) #1056 edges

#plotting subgraph
plot.igraph(sub.com.graph.2, vertex.size=10, layout=layout.fruchterman.reingold, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)

#summary
min.com <- group_by(teams.fast.greedy.min, team)
min.com.df <- as.data.frame(summarise(min.com, Members = n_distinct(name)))

#ordering by top teams 
min.teams.com <- arrange(top_n(min.com.df, 10), desc(Members))

#barplot
com.names <- min.teams.com$team
barplot(min.teams.com$Members,legend=rownames(min.teams.com$team), beside="TRUE", names.arg=com.names,  col = "dark gray", cex.names=0.6, las=2)



#subgraph of the smallest community
y <- which.min(sizes(com))
sub.com.graph.2 <- induced.subgraph(graph.authors.edge, which(membership(com) == y))
teams.fast.greedy.min <- tbl_df(as.data.frame(get.vertex.attribute(sub.com.graph.2)))




#ALTERNATIVE: SPINGLASS ALGORITHM Finds 10 communities
com2 <- spinglass.community(graph.authors.edge)
V(graph.authors.edge)$memb <- com2$membership
modularity(com2) #0.06072848

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

#STEP 10: Centrality and Power Measures - THIS IS OPTIONAL TO SUPPORT IDEAS
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