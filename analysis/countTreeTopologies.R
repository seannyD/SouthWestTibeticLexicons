# Find well-represented topologies
setwd("~/OneDrive - Cardiff University/Funding/InternationalStrategicFund/project/analysis/")
library(ape)
library('TreeTools')
library('phytools')


library(devtools)
#install_github('santiagosnchez/rBt')
library(rBt)

beast_output <- read.annot.beast("../results/BEAST/jml_combined2_relaxed_multiSite_fossilised/JMLwithSagart_combined_multisite.trees")
#beast_output_rooted <- root.multiPhylo(beast_output, c('taxon_A', 'taxon_B'))

beast_output = keep.tip(beast_output,c("Lowa","Sherpa","Jirel","Kagate","Tsum","Nubri","Gyalsumdo"))

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

write.csv(result,file="../results/BEAST/jml_combined2_relaxed_multiSite_fossilised/Topologies_count.csv")
saveRDS(unique_topologies,file = "../results/BEAST/jml_combined2_relaxed_multiSite_fossilised/Topologies_unique.rDAT")

# Plot
# Over half belonged to three typologies (out of a possible 10,395 binary rooted trees).
sum(result[1:3,]$percentage)
topThree = unique_topologies[result[1:3,]$unique_topology]

# 28%
pdf("../results/BEAST/jml_combined2_relaxed_multiSite_fossilised/topologyA.pdf",height=4,width=4)
plot(compute.brlen(as.phylo(topThree[1][[1]])))
dev.off()

# 12%
pdf("../results/BEAST/jml_combined2_relaxed_multiSite_fossilised/topologyB.pdf",height=4,width=4)
plot(compute.brlen(as.phylo(topThree[2][[1]])))
dev.off()

# 12%
pdf("../results/BEAST/jml_combined2_relaxed_multiSite_fossilised/topologyC.pdf",height=4,width=4)
plot(compute.brlen(as.phylo(topThree[3][[1]])))
dev.off()


