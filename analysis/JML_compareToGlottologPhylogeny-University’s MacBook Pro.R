library(phangorn)
library(ape)
library(caper)
library(stringr)
library(quartet)
library(vegan)
library(fields)
library(dendextend)

try(setwd("~/OneDrive - Cardiff University/Funding/InternationalStrategicFund/project/analysis/"))

trees = read.nexus(file="../results/BEAST/jml_combined2_relaxed_3site_fossilised/JMLwithSagart_combined_relaxed_3site.trees")
trees = trees[2000:length(trees)]

coreLangs = c("Gyalsumdo","Jirel","Kagate","Lowa","Nubri","Sherpa","Tsum","Yolmo")

m = matrix(nrow=length(trees),ncol=8)
colnames(m) = c("JS","NG","KY","KYTNG","L.out","CheckBayesClade","BL","SWTib")

for(i in 1:length(trees)){
  JS = is.monophyletic(trees[[i]],c("Jirel","Sherpa"))
  NG = is.monophyletic(trees[[i]],c("Nubri","Gyalsumdo"))
  KY = is.monophyletic(trees[[i]],c("Kagate","Yolmo"))
  KYTNG = is.monophyletic(trees[[i]],c("Kagate","Yolmo","Tsum","Nubri","Gyaldsumdo"))
  # test if Lowa is separate
  dists = cophenetic.phylo(trees[[i]])
  dists = dists[coreLangs,coreLangs]
  lowaIsMax = apply(dists,1,max) == dists["Lowa",]
  lowaIsMax = lowaIsMax[names(lowaIsMax)!="Lowa"]
  lowaIsOutlier = all(lowaIsMax)
  
  checkBayesClade = is.monophyletic(trees[[i]],c("Sherpa","Jirel","Yolmo","Kagate"))
  
  BL = is.monophyletic(trees[[i]],c("Batang","Lhasa"))
  
  # Is Southwestern tibetic placed below North Eastern?
  tx = keep.tip(trees[[i]],c("Jirel","Sherpa","Lhasa"))
  SWTibToBatang = max(phytools::nodeHeights(tx))
  tx2 = keep.tip(trees[[i]],c("Lhasa","Xiahe","Alike"))
  XAToBatang = max(phytools::nodeHeights(tx2))
  SWTib = XAToBatang > SWTibToBatang
  
  m[i,] = c(JS,NG,KY,KYTNG,lowaIsOutlier,checkBayesClade,BL,SWTib)
}

colSums(m)/nrow(m)


# QuartetDistance


glottologTree = read.tree(text="(Old Tibetan:1,((Alike,Xiahe),(Batang,(Lhasa,(Lowa,((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),(Sherpa,Jirel))))));")
glottologTree = compute.brlen(glottologTree)
glottologTree$edge.length[1] = 0.3
glottologTree = ladderize(glottologTree)
plot(glottologTree,cex=1,main="Glottolog tree",tip.color=c(1,1,1,1,1,2,2,2,2,2,2,2,2))

glottologTree = multi2di(glottologTree,random = F)

#mcct = read.nexus("../results/BEAST/jml_combined2_relaxed_multiSite_fossilised/JMLwithSagart_combined_multisite_MCCT.trees")
mcct = read.nexus("../results/BEAST/jml_combined2_relaxed_3site_fossilised/JMLwithSagart_combined_relaxed_3site_MCCT.trees")

plot(mcct)
abline(v=seq(0,7,by=1),col="gray")
abline(v=5.1,col="red")
abline(v=5.4,col="red")

mcct = drop.tip(mcct,"OldChinese")
mcct = drop.tip(mcct,"OldTibetan")

mcct = ladderize(mcct)


glottologTree = drop.tip(glottologTree,"OldChinese")
glottologTree = drop.tip(glottologTree,"OldTibetan")

tx = tanglegram(glottologTree,mcct,sort=T,
           main_left = "Glottolog",
           main_right = "Bayesian",
           highlight_branches_lwd = F,
           highlight_branches_col=F,
           margin_inner = 5,
           highlight_distinct_edges = F)
plot(tx)
pdf("../results/GlottoVersusBayesian.pdf",height=4,width=8)
tanglegram(glottologTree,mcct,sort=T,
           main_left = "Glottolog",
           main_right = "Bayesian",
           highlight_branches_lwd = F,
           highlight_branches_col=F,
           margin_inner = 5,
           highlight_distinct_edges = F,axes=F)
dev.off()

comparePhylo(glottologTree,mcct)

## Compare to Zhang

ztree = read.nexus("../data/Zhang_etal_2019/109SinoTibetanLanguages.MCC.tree")
comAnc = getMRCA(ztree,c("Cuona_Mama_Bodish","Tibetan_Jirel_Tibetan"))
ztree = extract.clade(ztree,comAnc)

ztree$tip.label = gsub(" ?Tibetan ?","",ztree$tip.label)
ztree$tip.label = gsub("^_","",ztree$tip.label)
ztree$tip.label = gsub("_$","",ztree$tip.label)
ztree$tip.label = gsub("_"," ",ztree$tip.label)

commonLangs = intersect(ztree$tip.label,mcct$tip.label)
ztree = keep.tip(ztree, commonLangs)
mcct2 = keep.tip(mcct,commonLangs)

mcct2$edge.length= mcct2$edge.length*1000
#mcct2 = ladderize(mcct2)
#mcct2 = rotate(mcct2,c(5))
#mcct2 = rotate(mcct2,c(6))
ztree2 = ladderize(ztree)

pdf("../results/ZhangVersusBayesian.pdf",height=4,width=8)
tanglegram(ztree2,mcct2,sort=F,
           main_left = "M. Zhang et al.",
           main_right = "Bayesian",
           highlight_branches_lwd = F,
           highlight_branches_col=F,
           margin_inner = 3.5,
           highlight_distinct_edges = F,
           axes = T,xlim=c(2600,0))
dev.off()


## Compare to H Zhang
hztree = read.nexus("../data/Zhang_Ji_Pagel_Mace_2020/41598_2021_85112_MOESM1_ESM_MCCT.trees")
tib = c("Alike_T","Xiaxe_T","Lhasa","Batang_T","Jirel","Sherpa")#,"Cuona_M","Motuo_M","Gurung","Tamang","Thakali","Kaike")
hztree = keep.tip(hztree, tib)


hztree$tip.label = gsub("_T","",hztree$tip.label)
hztree$tip.label[hztree$tip.label=="Xiaxe"] = "Xiahe"

mcct3 = keep.tip(mcct,hztree$tip.label)
#mcct3 = rotate(mcct3,c(7))
#mcct3 = rotate(mcct3,c(9))
mcct3 = ladderize(mcct3)
mcct3$edge.length= mcct3$edge.length*1000
hztree$edge.length = hztree$edge.length*1000

pdf("../results/HZhangVersusBayesian.pdf",height=4,width=8)
tanglegram(hztree,mcct3,sort=F,
           main_left = "H. Zhang et al.",
           main_right = "Bayesian",
           highlight_branches_lwd = F,
           highlight_branches_col=F,
           margin_inner = 3.5,
           highlight_distinct_edges = F,
           axes = T,xlim=c(2600,0))
dev.off()

# Compare to Sagart
stree = read.nexus("../data/Sagart_etal_2019/sinotibetan-beast-covarion-relaxed-fbd.mcct.trees")
comAnc = getMRCA(stree,c("TibetanLhasa","TibetanOldTibetan"))
stree = extract.clade(stree,comAnc)
stree$tip.label = gsub("^Tibetan","",stree$tip.label)
#stree$tip.label[stree$tip.label=="OldTibetan"] = "Old Tibetan"
stree$edge.length[8] = 1.2

mcct4 = read.nexus("../results/BEAST/jml_combined2_relaxed_3site_fossilised/JMLwithSagart_combined_relaxed_3site_MCCT.trees")
mcct4 = drop.tip(mcct4,"OldChinese")
mcct4 = ladderize(mcct4)
mcct4 = keep.tip(mcct4,stree$tip.label)
mcct4$edge.length[8] = 1.2

mcct4$edge.length= mcct4$edge.length*1000
stree$edge.length = stree$edge.length*1000

stree = phytools::force.ultrametric(stree)
mcct4 = phytools::force.ultrametric(mcct4)

pdf("../results/SagartVersusBayesian.pdf",width=8,height=4)
tanglegram(stree,mcct4,sort=T,
           main_left = "Sagart et al.",
           main_right = "Bayesian",
           highlight_branches_lwd = F,
           highlight_branches_col=F,
           margin_inner = 3.5,
           highlight_distinct_edges = F,
           axes = T,xlim=c(2600,0))
dev.off()

### Geography comparison
g = read.csv("../data/langaugeLocation.csv",stringsAsFactors = F,quote="")
g$source = factor(g$source,levels=c("S","DND"))
g = g[rev(order(g$source,g$lat,g$long)),]
g$language[g$language=="Yohlmo"] = "Yolmo"

geoDists = rdist.earth(cbind(g$long,g$lat),miles=F)
rownames(geoDists) = gsub(" ","",g$language)
colnames(geoDists) = gsub(" ","",g$language)

geoDists = geoDists[rownames(geoDists)!="OldTibetan",
                    colnames(geoDists)!="OldTibetan"]

#mcct = read.nexus("../results/BEAST/jml_combined_relaxed_multisite_fossilised/JMLwithSagart_combined_multisite_MCCT.trees")
mcct = read.nexus("../results/BEAST/jml_combined_relaxed_3site_fossilised/JMLwithSagart_combined_relaxed_3site_MCCT.trees")
mcct = drop.tip(mcct,"OldChinese")
mcct = drop.tip(mcct,"OldTibetan")

phyDists = cophenetic(mcct)
phyDists = phyDists[rownames(geoDists),colnames(geoDists)]

plot(geoDists,phyDists)

geoDistsD = as.matrix(as.dist(geoDists))
phyDistsD = as.matrix(as.dist(phyDists))
cost.geo.vs.phylo <- rbind(geoDistsD,phyDistsD)
res.cadm.max <- CADM.global(cost.geo.vs.phylo,2,ncol(geoDists),nperm = 10000) 
res.cadm.max

mt <-
  mantel(geoDists,phyDists, method="spearman", permutations=999, strata = NULL)
mt

# All trees

trees = read.nexus("../results/BEAST/jml_combined_relaxed_3site_fossilised/JMLwithSagart_combined_relaxed_3site.trees")

trees = trees[2000:length(trees)]

res = data.frame()
sel = seq(from=1,to=length(trees),by=18)
for(i in 1:length(trees)){
  if((i %% 1000)==0){
    print(i)
  }
  tree = trees[[i]]
  tree = drop.tip(tree,"OldChinese")
  tree = drop.tip(tree,"OldTibetan")
  phyDists = cophenetic(tree)
  phyDists = phyDists[rownames(geoDists),colnames(geoDists)]
  phyDistsD = as.matrix(as.dist(phyDists))
  mtX <-
    mantel(geoDists,phyDists, method="spearman", permutations=999, strata = NULL)
  
  cost.geo.vs.phylo <- rbind(geoDistsD,phyDistsD)
  res.cadm.max <- CADM.global(cost.geo.vs.phylo,2,ncol(geoDists),nperm = 1000,silent = T)
  res = rbind(res,data.frame(
    W = res.cadm.max$congruence_analysis[1],
    Chi2 = res.cadm.max$congruence_analysis[2],
    Prob.perm = res.cadm.max$congruence_analysis[3],
    mt.r = mtX$statistic,
    mt.p = mtX$signif
  ))
}

mean(res$W)
min(res$W)
max(res$Prob.perm)
write.csv(res,"../results/BEAST/jml_combined_relaxed_3site_fossilised/GeoPhyloDistances_GreatCircle.csv")
