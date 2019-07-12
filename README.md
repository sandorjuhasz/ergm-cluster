# ERGM (Exponential Random Graph Models)

###### This is a public repository for the article

Juhász, S. (2019): Spinoffs and tie formation in cluster knowledge networks. *Small Business Economics*, In Press. 

[Abstract]
*It is generally acknowledged that in order to have access to locally accumulated industrial knowledge firms have to collaborate and take part in cluster knowledge networks. This study argues that the inherited capabilities of spinoff enable them to cooperate and exchange knowledge more easily and to gain more from positive knowledge externalities in clusters. The basis of the analysis is a relational dataset on a printing and paper product cluster in Hungary and I use exponential random graph models to explain the formation of knowledge ties. I demonstrate that besides geographical proximity, ownership similarity and network structural effects, being a spinoff company enhances tie formation in the local network. Results suggest that spinoffs are indeed more likely to collaborate and take advantage of knowledge concentration.*

## Data


*Network*

The network (stored in matrix form) represents knowledge exchange between the firms in the printing and paper product cluster of Kecskemét, Hungary. 
The following question was used to collect relational data on knowledge sharing in the cluster:

*If you are in a critical situation and need technical advice, to which of the local firms mentioned in the roster do you turn?*

Therefore, the matrix represents an advice network, where companies in rows ask technical advice from companies in columns.
The networrk consists of 26 nodes (firms) and 223 edges.
file: *network_data.csv*


*Firm characteritics (properties)*

Different characteristics of firms (or network nodes) are also available.

Years in industry (age or experience of firms) := 'years_in_industry'

Export volume of firms (% from net revenuee) := 'export_vol'

Net revenue category := 'net_rev_cat'




*Similarity (proximity) of firms*



## Scripts

