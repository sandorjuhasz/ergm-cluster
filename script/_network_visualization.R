### visualization of the knowledge network between firms ###


# packages
library(data.table)
library(dplyr)
library(igraph)
library(ggraph)
library(smglr)

# for reproduction
set.seed(16)




##__ 1) plots to highlight spinoff companies in the network __##

## DATA PREP ## 

# graph from matrix
mat <-as.matrix(read.csv("../data/network_data.csv", sep=";", header=TRUE, row.names = 1))
graph <- graph.adjacency(mat)

# firm properties
prop <- fread("../data/firm_properties.csv", sep=";")

# add spinoff attribute
V(graph)$spinoff <- prop$spinoff

# assign colors
V(graph)[V(graph)$spinoff == 0]$color <- "white"
V(graph)[V(graph)$spinoff == 1]$color <- "grey"

# network layout
la <- layout_with_graphopt(graph, niter=500)*100


## PLOT
title <- "spinoffs_in_knowledge_network"
file_name <- paste("../figures/", title, ".png")
png(file_name, width=1200, height=900, units = 'px')

par(mar=c(1,1,0,0) + 0.1)

plot(graph, layout=la*1000,
	vertex.size=6+4*log(degree(graph, mode="in")),
	vertex.label.color="black",
	vertex.label.cex=1.65,
	edge.color="black",
	edge.arrow.size=0.35)
dev.off()




##__ 2) old Petofi Press as FOCAL node __##
## 2A) full network


## DATA PREP ## 

# graph from matrix
mat <-as.matrix(read.csv("../data/network_data.csv", sep=";", header=TRUE, row.names = 1))
graph <- graph.adjacency(mat)

# firm properties
prop <- fread("../data/firm_properties.csv", sep=";")

# mark Petofi Press - the focal node
prop$petofi <- 0
prop$petofi[which(prop$ID == "P20")] <- 1

# add spinoff attribute
V(graph)$spinoff <- prop$spinoff
V(graph)$petofi <- prop$petofi


# full network layout
layout_full <- data.frame(layout_with_focus(graph, 19, iter=500, tol=0.1))
layout_full$ID <- prop$ID

# full graph plot
title <- "focal_Petofi_graph_full"
file_name <- paste("../figures/", title, ".png")
png(file_name, width=600, height=600, units = 'px')

ggraph(graph, layout="manual",
	node.positions = data.frame(x = layout_full[,1], y = layout_full[,2])) +
	draw_circle(use = "focus", max.circle = 2) +
	geom_edge_link(edge_color = "black", edge_width = 0.3) +
	geom_node_point(aes(fill = as.factor(petofi), size = as.factor(petofi)), shape = 21) +
	scale_fill_manual(values=c("grey", "lightblue1")) +
	scale_size_manual(values=c(10, 25)) +
	theme_graph() +
	theme(legend.position = "none") +
	coord_fixed()
dev.off()



##__ 2) old Petofi Press as FOCAL node __##
## 2B) only spinoffs and focal node

## DATA PREP ##

# keep spinoffs ONLY
spin_ids <- select(filter(prop, spinoff==1), ID)
spin_ids <- spin_ids$ID
spin_ids <- c(spin_ids, "P20") # PETOFI = P20

graph2 <- induced_subgraph(graph, spin_ids)

# subgraph layout
layout_small <- filter(layout_full, ID %in% spin_ids)

# subgraph plot
title <- "only_spinoffs_and_focal"
file_name <- paste("../figures/", title, ".png")
png(file_name, width=600, height=600, units = 'px')

ggraph(graph2, layout="manual",
	node.positions = data.frame(x = layout_small[,1], y = layout_small[,2])) +
	draw_circle(use = "focus", max.circle = 2) +
	geom_edge_link(edge_color = "black", edge_width = 0.3) +
	geom_node_point(aes(fill = as.factor(petofi), size = as.factor(petofi)), shape = 21) +
	scale_fill_manual(values=c("grey", "lightblue1")) +
	scale_size_manual(values=c(10, 25)) +
	theme_graph() +
	theme(legend.position = "none") +
	coord_fixed()
dev.off()





