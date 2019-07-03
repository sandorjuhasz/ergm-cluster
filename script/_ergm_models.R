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


#### I STAND THERE


# manipulate properties
properties$export_dummy <- 0
properties$export_dummy[properties$export_vol > 0] <- 1
properties$ln_emp <- log(properties$employee)

# create _network object
network_data <-read.csv("Knetwork2012.csv", sep=";", header=TRUE, row.names = 1)
Knet2 <- as.network(as.matrix(network_data), directed=TRUE)

# add attributes
network::set.vertex.attribute(Knet2, "experience", properties$years_in_industry)
set.vertex.attribute(Knet2, "ln_emp", properties$ln_emp)
set.vertex.attribute(Knet2, "emp", properties$employee)
set.vertex.attribute(Knet2, "export_dummy", properties$export_dummy)
set.vertex.attribute(Knet2, "net_rev_category", properties$net_rev_cat)
set.vertex.attribute(Knet2, "f_owner", properties$f_owner)
set.vertex.attribute(Knet2, "external_links", properties$external_links)
set.vertex.attribute(Knet2, "spinoff", properties$spinoff)
set.vertex.attribute(Knet2, "profile", properties$main_field)
set.vertex.attribute(Knet2, "petofi_spinoff", properties$petofi_spinoff)

# add proximities
cogprox <- as.matrix(read.csv("cog012.csv", sep=";", header=TRUE, row.names = 1))
geoprox <- as.matrix(read.csv("geo_matrix.csv", sep=";", header=TRUE, row.names = 1))
ownerprox <- as.matrix(read.csv("ownership_proximity.csv", sep=";", header=TRUE, row.names=1))

cog_network <- as.network(as.matrix(cogprox), directed = TRUE)
geo_network <- as.network(as.matrix(geoprox), directed = TRUE)
owner_network <- as.network(as.matrix(ownerprox), directed = TRUE)

set.edge.value(cog_network, 'cogprox', cogprox)
set.edge.value(geo_network, "geoprox", geoprox)
set.edge.value(owner_network, 'ownerprox', ownerprox)

#summary(Knet2)



 ## refined model ##
refined <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + nodefactor("spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner", diff=FALSE) + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(refined)

refined <- summary(further01)
capture.output(refined, file="refined.txt")

## main model ##
main01 <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + gwidegree(1.325, fixed=TRUE) + nodefactor("spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner", diff=FALSE) + nodecov("experience") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(main01)


## main model ##
null_model <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + gwidegree(1.325, fixed=TRUE) + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner", diff=FALSE) + nodecov("experience") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(null_model)



## main model with PETOFI spinoff var ##
petofi_model <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + gwidegree(1.325, fixed=TRUE) + nodefactor("petofi_spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner", diff=FALSE) + nodecov("experience") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(petofi_model)

## refined with PETOFI spinoff var
petofi_refined <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + nodefactor("petofi_spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner", diff=FALSE) + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(petofi_refined)




main <- summary(main01)
capture.output(main, file="main_model.txt")

model_gof <- gof(further02 ~ espartners + distance) ## very bad
plot(model_gof)









 ## main model ##
main01 <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + gwidegree(1.325, fixed=TRUE) + nodefactor("spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner") + nodecov("experience") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(main01)

main <- summary(main01)
capture.output(main, file="main_model.txt")

model_gof <- gof(further02 ~ espartners + distance) ## very bad
plot(model_gof)


















## experiment with model settings

model_00 <- ergm(Knet2 ~ edges + mutual)
summary(model_00)

mcmc.diagnostics(model_00)

model_00_gof <- gof(model_00 ~ espartners)
plot(model_00_gof)
model_00_gof <- gof(model_00 ~ distance)
plot(model_00_gof)
model_00_gof <- gof(model_00 ~ odegree)
plot(model_00_gof)
model_00_gof <- gof(model_00 ~ idegree)
plot(model_00_gof)


model_01 <-  ergm(Knet2 ~ edges + mutual + gwesp(0.25, fixed=TRUE))
summary(model_01)

mcmc.diagnostics(model_01) ## so far it is veery good!!

model_01_gof <- gof(model_01 ~ espartners) ## very bad
plot(model_01_gof)
model_01_gof <- gof(model_01 ~ distance) ## usual 
plot(model_01_gof)
model_01_gof <- gof(model_01 ~ odegree) ## between 7-10 it is waay under than expected
plot(model_01_gof)
model_01_gof <- gof(model_01 ~ idegree) ## indegree 7 & indegree 11-12 is waay under than expected
plot(model_01_gof)


model_02 <- ergm(Knet2 ~ edges + mutual + gwesp(0.4, fixed=TRUE))
summary(model_02)

mcmc.diagnostics(model_02) ## veery bad!! stick to 0.2 fixed


model_03 <- ergm(Knet2 ~ edges + mutual + gwesp(0.25, fixed=TRUE) + odegree(7:10))
summary(model_03)

mcmc.diagnostics(model_03)

model_03_gof <- gof(model_03 ~ odegree) ## better but nit soo nice
plot(model_03_gof)


model_04 <- ergm(Knet2 ~ edges + mutual + gwesp(0.25, fixed=TRUE) + gwodegree(0.3, fixed=TRUE))

#model_04 <- ergm(Knet2 ~ edges + mutual + gwesp(0.25, fixed=TRUE), control = control.ergm(MCMC.samplesize = 10000, MCMC.interval = 1000))
#summary(model_04)

model_04 <- ergm(Knet2 ~ edges + mutual + gwesp(0.3, fixed=TRUE))
summary(model_04)

mcmc.diagnostics(model_04)

model_04_gof <- gof(model_04 ~ espartners) ## very bad
plot(model_04_gof)
model_04_gof <- gof(model_04 ~ distance) ## usual 
plot(model_04_gof)


## gwesp - gwidegree - cool!
model_test <- ergm(Knet2 ~ edges + mutual + gwesp(0.3, fixed=TRUE) + gwidegree(1.1, fixed=TRUE))
summary(model_test)


model_test2 <- ergm(Knet2 ~ edges + mutual + gwesp(0.325, fixed=TRUE) + gwidegree(1, fixed=TRUE) + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox") + nodefactor("spinoff"))
summary(model_test2)



model_test3 <- ergm(Knet2 ~ edges + mutual + gwesp(0.325, fixed=TRUE) + gwidegree(1, fixed=TRUE) + gwdsp(2, fixed=TRUE), control=control.ergm(MCMLE.maxit=3))


####mcmc-diagnostics - the BEST!!
model_test3 <- ergm(Knet2 ~ edges + mutual + gwesp(0.325, fixed=TRUE) + gwidegree(1, fixed=TRUE) + gwdsp(1.725, fixed=TRUE))
summary(model_test3)

mcmc.diagnostics(model_test3)



model_test_gof <- gof(model_test3 ~ espartners) ## very bad
plot(model_test_gof)
model_test_gof <- gof(model_test3 ~ distance) ## usual 
plot(model_test_gof)
model_test_gof <- gof(model_test3 ~ idegree) ## usual 
plot(model_test_gof)



## improved gwidegree - cool 2 !!
model_test4 <- ergm(Knet2 ~ edges + mutual + gwesp(0.325, fixed=TRUE) + gwidegree(1.325, fixed=TRUE) + gwdsp(1.725, fixed=TRUE))
summary(model_test4)

mcmc.diagnostics(model_test4)

model_test_gof <- gof(model_test4 ~ espartners + distance) ## very bad
plot(model_test_gof)
model_test_gof <- gof(model_test4 ~ distance) ## usual 
plot(model_test_gof)
model_test_gof <- gof(model_test4 ~ idegree) ## usual 
plot(model_test_gof)



## all in ERGM2
all_in_ERGM2 <- ergm(Knet2 ~ edges + mutual + nodecov("experience") + nodecov("ln_emp") + nodefactor("f_owner") + nodecov("external_links") + nodefactor("spinoff") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox") + gwesp(0.325, fixed=TRUE) + gwidegree(1.1, fixed=TRUE) + gwdsp(1.725, fixed=TRUE))   ## add robuestness with more round
summary(all_in_ERGM2)

title <- "mcmc_diagn"
file_name <- paste("/Users/juhaszsandor/Documents/School/PhD/RESEARCH/KC3 [2018] ergm/GOF_plots/", title, ".png")
png(file_name, width=12, height=8, units = 'in', res=72)
mcmc_diagn <- mcmc.diagnostics(all_in_ERGM2)
plot(mcmc_diagn)
dev.off()


mcmc.diagnostics(all_in_ERGM2)


model_test_gof <- gof(all_in_ERGM2 ~ espartners) ## very bad
plot(model_test_gof)
model_test_gof <- gof(all_in_ERGM2 ~ distance) ## usual 
plot(model_test_gof)
model_test_gof <- gof(all_in_ERGM2 ~ idegree) ## usual 
plot(model_test_gof)








 ## refined model ##
further01 <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + nodefactor("spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(further01)

refined <- summary(further01)
capture.output(refined, file="refined.txt")


, control=control.ergm(MCMLE.maxit=2)

mcmc <- mcmc.diagnostics(further01)
plot(mcmc)

par(mfrow=c(1,3)) # Setup a 2 panel plot (for later)
model_gof <- gof(further01 ~ espartners + distance + idegree) ## very bad
plot(model_gof)

model_gof <- gof(further01 ~ distance) ## usual 
plot(model_gof)
model_gof <- gof(further01 ~ idegree) ## usual 
plot(model_gof)



 ## main model ##
main01 <- ergm(Knet2 ~ edges + mutual + gwesp(0.32, fixed=TRUE) + gwdsp(1.725, fixed=TRUE) + gwidegree(1.325, fixed=TRUE) + nodefactor("spinoff") + nodecov("ln_emp")  + nodecov("external_links") + nodematch("f_owner") + nodecov("experience") + edgecov(geo_network, "geoprox") + edgecov(cog_network, "cogprox"))
summary(main01)

main <- summary(main01)
capture.output(main, file="main_model.txt")

model_gof <- gof(further02 ~ espartners + distance) ## very bad
plot(model_gof)

## lets stop here
# m1 - baseline_02



