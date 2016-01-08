library(dplyr)
library(reshape2)
library(igraph)

data <- read.csv(file="soccer_preprocessed_data_v2.csv",head=TRUE,sep=",")

#STEP 1: CREATE THE ADJACENCY MATRIX FOR THE GRAPH
authors.and.topics <- select(data, author, parent_id) #with parent_id matrix is 5 million

#convert it into an adjacent matrix so that we can plot the graph
#http://web.stanford.edu/~messing/Affiliation%20Data.html
M = as.matrix(table(authors.and.topics)) # restructure your network data in matrix format
m = table(authors.and.topics)
M = as.matrix(m)
Mrow = M %*% t(M) #Mrow will be the one-mode matrix formed by the row entities. 110 MB

#STEP 2: USING IGRAPH TO CONSTRUCT THE GRAPH
#http://jfaganuk.github.io/2015/01/02/analyzing-a-basic-network/

graph.data.order <- melt(Mrow, id.vars = c('author')) #Using graph.data.frame to reshape the matrix so that it is not wide, but tall
colnames(graph.data.order) <- c('source','target','weight') # changing the column names to a different format
graph.authors <- graph.data.frame(graph.data.order, directed = F) # make it into a graph data frame, the format for igraph
graph.authors <- simplify(graph.authors, remove.loops = T, remove.multiple = T)#removing self loops

#STEP 3: MATCHING THE TEAMS TO EACH OF THE NODES IN THE GRAPH
#code source: http://www.shizukalab.com/toolkits/sna/plotting-networks-pt-2
list.vertex.attributes(graph.authors) #this gets the attributes attached to the vertixes or nodes
V(graph.authors)$team=as.character(data$author_flair_text[match(V(graph.authors)$name,data$author)]) #matching teams with authors
V(graph.authors)$controversial=as.character(data$controversiality[match(V(graph.authors)$name,data$author)]) #matching teams with authors
V(graph.authors)$score=as.character(data$score[match(V(graph.authors)$name,data$author)]) #matching teams with authors

#STEP 4: CREATING A SUBGRAPH WITH ELEMENTS THAT HAVE WEIGHT OVER 5 and PLOTTING
# filter the network based on weight over 5... if we leave vertices with edges<5 then it looks very messy
graph.authors.edge <- subgraph.edges(graph.authors, which(E(graph.authors)$weight >= 25))

      #Original network size
      vcount(graph.authors)
      ecount(graph.authors)
      # 4114 nodes / 8460441 edges...
      
      #Subgraph
      vcount(graph.authors.edge)
      ecount(graph.authors.edge)
      #Weight 5: 3353 nodes / 539415 edges
      #Weight 25: 2810 nodes / 170228 edges

#STEP 5: FINDING COMMUNITIES WITH THE FAST GREEDY ALGORITHM
com <- fastgreedy.community(graph.authors.edge)
V(graph.authors.edge)$memb <- com$membership
modularity(com) #0.1281404
      
      #plotting community
plot(com, graph.authors.edge, vertex.size=5, layout=layout.fruchterman.reingold, vertex.label=NA, edge.arrow.size=0.2, edge.color="dark grey", edge.label.font=0.5)

#subgraph of the largest community
x <- which.max(sizes(com))
sub.com.graph <- induced.subgraph(graph.authors.edge, which(membership(com) == 2))
      
      vcount(sub.com.graph) #1919 nodes
      ecount(sub.com.graph) #56378 edges
      
      #subgraph of the smallest community
      z <- which.min(sizes(com))
      sub.com.graph.2 <- induced.subgraph(graph.authors.edge, which(membership(com) == 4))
      
      vcount(sub.com.graph.2) #199 nodes
      ecount(sub.com.graph.2) #2332 edges
      
      #STEP 6: EXPORTING GRAPHS FOR FURTHER ANALYSIS IN GELPHI
      # Exporting community to gelphi
      source("iGraph_GexF_Exporter.R")
      saveAsGEXF(graph.authors.edge, "complete_graph_communities_soccer.gexf")
      saveAsGEXF(sub.com.graph, "community_largest_soccer.gexf")
      saveAsGEXF(sub.com.graph.2, "community_smallest_soccer.gexf")

