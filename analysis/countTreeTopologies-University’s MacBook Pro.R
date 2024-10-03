# Find well-represented topologies
setwd("~/OneDrive - Cardiff University/Funding/InternationalStrategicFund/project/analysis/")
library(ape)
library('TreeTools')
library('phytools')


library(devtools)
#install_github('santiagosnchez/rBt')
library(rBt)

#beast_output <- read.annot.beast("../results/BEAST/jml_combined2_relaxed_3site_fossilised/JMLwithSagart_combined2_relaxed_3site.trees")
beast_output <- read.annot.beast("../results/BEAST/jml_combined2_relaxed_3site_fossilised/JMLwithSagart_combined_relaxed_3site.trees")
beast_output = keep.tip(beast_output,c("Lowa","Sherpa","Jirel","Kagate","Tsum","Nubri","Gyalsumdo", "Yolmo"))

# Ignore burn-in
beast_output = beast_output[2000:20000]

unique_topologies <- unique.multiPhylo(beast_output)

count <- function(item, list) {
  total = 0
  for (i in 1:length(list)) {
    if (all.equal.phylo(item, list[[i]], use.edge.length = FALSE)) {
      total = total + 1
    }
  }
  return(total)
}

result <- data.frame(unique_topology = rep(0, length(unique_topologies)),
                     count = rep(0, length(unique_topologies)))
for (i in 1:length(unique_topologies)) {
  result[i, ] <- c(i, count(unique_topologies[[i]], beast_output))
}

result$percentage <- ((result$count/length(beast_output))*100)

result = result[order(result$percentage,decreasing = T),]

write.csv(result,file="../results/BEAST/jml_combined2_relaxed_3site_fossilised/Topologies_count.csv")
saveRDS(unique_topologies,file = "../results/BEAST/jml_combined2_relaxed_3site_fossilised/Topologies_unique.rDAT")

# Plot
# Over half belonged to three typologies (out of a possible 10,395 binary rooted trees).
sum(result[1:3,]$percentage)
topThree = unique_topologies[result[1:3,]$unique_topology]

# 31%
pdf("../results/BEAST/jml_combined2_relaxed_3site_fossilised/topologyA.pdf",height=4,width=4)
plot(compute.brlen(as.phylo(topThree[1][[1]])))
dev.off()

# 13%
pdf("../results/BEAST/jml_combined2_relaxed_3site_fossilised/topologyB.pdf",height=4,width=4)
plot(compute.brlen(as.phylo(topThree[2][[1]])))
dev.off()

# 13%
pdf("../results/BEAST/jml_combined2_relaxed_3site_fossilised/topologyC.pdf",height=4,width=4)
plot(compute.brlen(as.phylo(topThree[3][[1]])))
dev.off()


# Does Tsum pair with Kagate, Nubri or Gyalsumdo?

d = read.csv("../data/JML_Cognate_Coding/JML_withSagart_combined2.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F)
d = d[d$DOCULECT %in% c("Tsum","Gyalsumdo","Kagate","Nubri"),]

mx = matrix(0,nrow=4,ncol=4)
rownames(mx) = c("Tsum","Gyalsumdo","Kagate","Nubri")
colnames(mx) = c("Tsum","Gyalsumdo","Kagate","Nubri")

for(i in 1:length(rownames(mx))){
  for(j in 1:length(colnames(mx))){
    di = d[d$DOCULECT==rownames(mx)[i],]
    dj = d[d$DOCULECT==colnames(mx)[j],]
    mx[i,j] = mx[i,j]  + sum(unique(di$COGID) %in% unique(dj$COGID))
  }
}

dT = d[d$DOCULECT=="Tsum",]
dTCogs = unique(dT$COGID)
out = list()
for(lx in c("Gyalsumdo","Kagate","Nubri")){
  dx = d[d$DOCULECT==lx,]
  otherLangs = c("Gyalsumdo","Kagate","Nubri")
  otherLangs = otherLangs[otherLangs!=lx]
  otherx = d[d$DOCULECT %in% otherLangs,]
  uConcepts = dx[(dx$COGID %in% dTCogs) & (!dx$COGID %in% otherx$COGID),]$CONCEPT
  out[[lx]] = uConcepts
}

# Wheat and Barley?
# Wheat and Barley production stats from e.g.
# Barley is from the north, wheat from the south
# (do I measure Yeild or Production?)
# https://nepstat.iids.org.np/search?str=barley&items_per_page=All&facet[0]=category%3A281
#https://nepstat.iids.org.np/search?str=barley&items_per_page=All&facet[0]=category%3A281

# Get a list of concepts that fit a particular pattern
# e.g. if all langs have the cogid in common
lxs = c("Tsum", "Gyalsumdo","Kagate","Nubri")
#patts = expand.grid(c(T,F),c(T,F),c(T,F),c(T,F))
#colnames(patts) = lxs
#patts$Concepts = ""
res = data.frame(COGID=NA,patt=NA,CONCEPT=NA)
allCogs = unique(d$COGID)
for(cx in unique(d$COGID)){
  dx = d[d$COGID==cx,]
  xpatt = sapply(lxs,function(lx){cx %in% dx[dx$DOCULECT==lx,]$COGID})
  res = rbind(res,data.frame(
    COGID=cx,patt=paste(xpatt,collapse=","),CONCEPT=dx$CONCEPT[1]
  ))
}
res = res[!is.na(res$patt),]
res2 = data.frame(pattern = unique(res$patt))
res2$CONCEPT = sapply(res2$pattern,function(px){
  paste(unique(res[res$patt==px,]$CONCEPT),collapse=", ")
})
res2 = cbind(res2,t(sapply(res2$pattern,function(X){strsplit(X,",")[[1]]})))
colnames(res2)[3:6] = lxs
write.csv(res2,"../results/distances/TGKN.csv")



########
# Same but for northern section

beast_output <- read.annot.beast("../results/BEAST/jml_combined2_relaxed_3site_fossilised/JMLwithSagart_combined_relaxed_3site.trees")
beast_output = keep.tip(beast_output,c("Batang","Lhasa","Jirel"))

# Ignore burn-in
beast_output = beast_output[2000:20000]

unique_topologies <- unique.multiPhylo(beast_output)

count <- function(item, list) {
  total = 0
  for (i in 1:length(list)) {
    if (all.equal.phylo(item, list[[i]], use.edge.length = FALSE)) {
      total = total + 1
    }
  }
  return(total)
}

result2 <- data.frame(unique_topology = rep(0, length(unique_topologies)),
                     count = rep(0, length(unique_topologies)))
for (i in 1:length(unique_topologies)) {
  result2[i, ] <- c(i, count(unique_topologies[[i]], beast_output))
}

result2$percentage <- ((result2$count/length(beast_output))*100)

result2 = result2[order(result2$percentage,decreasing = T),]

sum(result2[1:2,]$percentage)

topThreeX = unique_topologies[result2[1:3,]$unique_topology]

plot(compute.brlen(as.phylo(topThreeX[1][[1]])))
plot(compute.brlen(as.phylo(topThreeX[2][[1]])))
plot(compute.brlen(as.phylo(topThreeX[3][[1]])))

