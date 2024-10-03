library(ape)
library(phytools)
try(setwd("~/OneDrive - Cardiff University/Funding/InternationalStrategicFund/project/visualisation/"))

#(Old Tibetan,((Alike,Xiahe),(Batang,(Lhasa,(((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),Lowa,(Sherpa,Jirel)))));

#glottologTree = read.tree(text="(((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),Lowa,(Sherpa,Jirel));")
glottologTree = read.tree(text="(Old Tibetan:1,((Alike,Xiahe),(Batang,(Lhasa,(((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),Lowa,(Sherpa,Jirel))))));")
glottologTree = compute.brlen(glottologTree)
glottologTree$edge.length[1] = 0.3
glottologTree = ladderize(glottologTree)
plot(glottologTree,cex=1,main="Glottolog tree",tip.color=c(1,1,1,1,1,2,2,2,2,2,2,2,2))

pdf("../results/GlottoTree.pdf")
plot(glottologTree,cex=1,main="Glottolog tree",tip.color=c(1,1,1,1,1,2,2,2,2,2,2,2,2))
dev.off()

# Full glottolog tree
gtree = read.tree("../data/reference/glottolog_sino1245.newick.txt")
gtree$tip.label = gsub("Baragaunle \\[bara1356\\]","Lowa [lowa1242]",gtree$tip.label)

gtree$tip.label = gsub("Shando \\[shan1295\\]","Alike [amdo1237]",gtree$tip.label)
gtree$tip.label = gsub("Padma \\[padm1234\\]","Xiahe [amdo1237]",gtree$tip.label)
gtree$tip.label = gsub("Chaphreng Tibetan \\[chap1275\\]","Batang [kham1282]",gtree$tip.label)
gtree$tip.label = gsub("Chaphreng Tibetan \\[chap1275\\]","Batang [kham1282]",gtree$tip.label)
gtree$tip.label = gsub("Khumbu \\[khum1246\\]","Sherpa [sher1255]",gtree$tip.label)
gtree$tip.label = gsub("Lho \\[lhoo1238\\]", "Nubri [nubr1243]",gtree$tip.label)

#gtree = drop.tip(gtree,c("Baragaunle [bara1356]","Upper Mustang [uppe1408]"))
lx = read.csv("../data/languages_to_glotto.tab",sep="\t")
lx = lx[c(-6,-7,-8),]
gtarget = c(lx$glotto,"amdo1237","amdo1237","kham1282","utsa1239","clas1254")
gtx = sapply(gtree$tip.label,function(X){
  any(sapply(gtarget,function(Y){grepl(Y,X)}))
})
gtree = drop.tip(gtree,
                 gtree$tip.label[!gtx])
gtree = force.ultrametric(gtree)
gtree$edge.length[which(gtree$edge.length==max(gtree$edge.length))] = 0

gtree$tip.label = gsub(" \\[.+","",gtree$tip.label)
gtree$tip.label = gsub("Lamjung ","",gtree$tip.label)
gtree$tip.label = gsub("'","",gtree$tip.label)
gtree$tip.label = gsub("Classical","Old",gtree$tip.label)


gtree = rotateNodes(gtree, c(14,23,19,22,21))
gtree = rotateNodes(gtree, c(19))

pdf("../results/GlottoTreeFull.pdf")
plot(gtree)
dev.off()

TreeTools::NewickTree(gtree)

#tree5 = read.tree(text="(((Gyalsumdo,Nubri),Tsum),Lowa,Jirel);")
#plot(tree5,cex=2)

# Zhang et al tree
ztree = read.nexus("../data/Zhang_etal_2019/109SinoTibetanLanguages.MCC.tree")
comAnc = getMRCA(ztree,c("Tibetan_Lhasa_Tibetan","Tibetan_Jirel_Tibetan"))
ztree = extract.clade(ztree,comAnc)

ztree$tip.label = gsub(" ?Tibetan ?","",ztree$tip.label)
ztree$tip.label = gsub("^_","",ztree$tip.label)
ztree$tip.label = gsub("_$","",ztree$tip.label)
ztree$tip.label = gsub("_"," ",ztree$tip.label)

pdf("../results/ZhangEtAlTree.pdf",height = 4)
ape::plot.phylo(ztree,tip.color = 1+(ztree$tip.label=="Jirel"))
maxH = max(nodeHeights(ztree))
axis(1,at = c(maxH-1000,maxH-500,maxH),labels = c(1000,500,0),line=1.5)
dev.off()

# Sagart tree

stree = read.nexus("../data/Sagart_etal_2019/sinotibetan-beast-covarion-relaxed-fbd.mcct.trees")
comAnc = getMRCA(stree,c("TibetanLhasa","TibetanOldTibetan"))
stree = extract.clade(stree,comAnc)
stree$tip.label = gsub("^Tibetan","",stree$tip.label)

pdf("../results/SagartEtAlStree.pdf",height = 3)
plot(stree,x.lim = c(-0.25,2))
maxH = max(nodeHeights(stree))
axis(1,at = c(maxH-1.5,maxH-1,maxH-0.5,maxH),labels = c(1500,1000,500,0),line=1.5)
dev.off()


# HZ tree (2020)

hztree = read.nexus("../data/Zhang_Ji_Pagel_Mace_2020/41598_2021_85112_MOESM1_ESM_MCCT.trees")
tib = c("Alike_T","Xiaxe_T","Lhasa","Batang_T","Writ_Tib","Jirel","Sherpa")#,"Cuona_M","Motuo_M","Gurung","Tamang","Thakali","Kaike")
hztree = keep.tip(hztree, tib)


hztree$tip.label = gsub("_T","",hztree$tip.label)
hztree$tip.label[hztree$tip.label=="Xiaxe_T"] = "Xiahe"

hztree = rotate(hztree,c(8))
hztree = rotate(hztree,12)
hztree = rotate(hztree,13)
hztree = untangle(hztree,"read.tree")

pdf("../results/HZhangTree.pdf",height = 4)
plot(hztree,x.lim = c(-0.3,1))
maxH = max(nodeHeights(hztree))
axis(1,at = c(maxH-1,maxH-0.5,maxH),labels = c(1000,500,0),line=1.5)
dev.off()