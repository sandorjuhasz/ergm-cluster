### ERGM on a firm level knowledge network ###


# packages
library(ergm) ## ?ergm // help("ergm-terms")
library(latticeExtra)
library(data.table)

# for reproduction
set.seed(10)

# setup a 2 panel plot (for later)
par(mfrow=c(1,2)) 



## DATA PREP ##

# firm properties dataframe
properties <- fread("../data/firm_properties.csv", sep=";")

# manipulate properties
properties$export_dummy <- 0
properties$export_dummy[properties$export_vol > 0] <- 1
properties$ln_emp <- log(properties$employee)

# create _network object
Knet <-as.network(as.matrix(read.csv("network_data.csv", sep=";", header=TRUE, row.names = 1)), directed=TRUE)

# add attributes
network::set.vertex.attribute(Knet, "experience", properties$years_in_industry)
set.vertex.attribute(Knet, "ln_emp", properties$ln_emp)
set.vertex.attribute(Knet, "emp", properties$employee)
set.vertex.attribute(Knet, "export_dummy", properties$export_dummy)
set.vertex.attribute(Knet, "net_rev_category", properties$net_rev_cat)
set.vertex.attribute(Knet, "f_owner", properties$f_owner)
set.vertex.attribute(Knet, "external_links", properties$external_links)
set.vertex.attribute(Knet, "spinoff", properties$spinoff)
set.vertex.attribute(Knet, "profile", properties$main_field)
set.vertex.attribute(Knet, "petofi_spinoff", properties$petofi_spinoff)

# add proximities
cogprox <- as.matrix(read.csv("cog_prox_matrix.csv", sep=";", header=TRUE, row.names = 1))
geoprox <- as.matrix(read.csv("geo_prox_matrix.csv", sep=";", header=TRUE, row.names = 1))

cog_network <- as.network(as.matrix(cogprox), directed = TRUE)
geo_network <- as.network(as.matrix(geoprox), directed = TRUE)

set.edge.value(cog_network, 'cogprox', cogprox)
set.edge.value(geo_network, "geoprox", geoprox)

# check the network
# summary(Knet)


### 2 final models ###

## main model ##
main01 <- ergm(Knet ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + gwidegree(1.325, fixed=TRUE) + nodefactor("spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner", diff=FALSE) + nodecov("experience") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(main01)

main <- summary(main01)
capture.output(main, file="../model_outputs/main_model.txt")


## refined model ##
refined <- ergm(Knet ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + nodefactor("spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner", diff=FALSE) + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(refined)

refined_out <- summary(refined)
capture.output(refined_out, file="../model_outputs/refined_model.txt")



## Goodness-of-Fit checks

# main model
mcmc_main <- mcmc.diagnostics(main01)
plot(mcmc_main)

main_gof01 <- gof(main01 ~ espartners + distance + idegree) ## very bad
plot(main_gof01)

main_gof02 <- gof(main01 ~ distance) ## usual 
plot(main_gof02)

main_gof03 <- gof(main01 ~ idegree) ## usual 
plot(main_gof03)


# refined model
mcmc_refined <- mcmc.diagnostics(refined)
plot(mcmc_refined)

refined_gof01 <- gof(refined ~ espartners + distance + idegree) ## very bad
plot(refined_gof01)

refined_gof02 <- gof(refined ~ distance) ## usual 
plot(refined_gof02)

refined_gof03 <- gof(refined ~ idegree) ## usual 
plot(refined_gof03)









