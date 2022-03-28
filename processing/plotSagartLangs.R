library(ape)
library(phytools)
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

source("../analysis/getGlottologTree.R")

d = read.csv("../data/Sagart_etal_2019/sino-tibetan-cleaned.tsv",stringsAsFactors = F,sep="\t",fileEncoding = "UTF-8",encoding = "UTF-8",quote='')

langs = read.csv("../data/Sagart_etal_2019/languages.csv",stringsAsFactors = F)

tLangs = read.csv("../data/languages_to_glotto.tab",stringsAsFactors = F, sep="\t",quote='')
tData = read.delim("../data/processed/240WordList/AllLangs_240.qlc",sep="\t",fileEncoding = "UTF-8",encoding = "UTF-8")

sort(unique(d$DOCULECT))

#dLangs$glotto %in% langs$Glottocode
#d = d[grepl("Tibetan",d$DOCULECT),]
#sort(unique(d$CONCEPT))

g = read.csv("../../../../Bristol/word2vec/word2vec_DPLACE/data/glottolog-languoid.csv/languoid.csv",stringsAsFactors = F)
g$family = g[match(g$family_pk,g$pk),]$name
#d[d$CONCEPT=='the head',]

# Re-download tree
# Load glottolog tree
# rename tips to glotto codes
pdf('../results/GlottoTree_withSagart.pdf',height=50)
t = getGlottologTree("../data/Sagart_etal_2019/glottolog_sino1245.nwk",langNodesToTips = T)
t = compute.brlen(t,power = 0.5)
par(mar=c(3,2,2,4))
plot(t, show.tip.label = F)#T, tip.color = 1+(t$tip.label %in% tLangs$glotto))
tiplabels(t$tip.label[which(t$tip.label %in% langs$Glottocode)],which(t$tip.label %in% langs$Glottocode),col = 2,adj=0,xpd=T)
nodelabels(t$node.label[which(t$node.label %in% langs$Glottocode)],which(t$node.label %in% langs$Glottocode),col = 2,adj=0,xpd=T)
tiplabels(t$tip.label[which(t$tip.label %in% tLangs$glotto)],which(t$tip.label %in% tLangs$glotto),bg = "green",adj=0,xpd=T)
nodelabels(t$node.label[which(t$node.label %in% tLangs$glotto)],which(t$node.label %in% tLangs$glotto),bg = "green",adj=0,xpd=T)
t$node.label = g[match(t$node.label,g$id),]$name
nodelabels(t$node.label,bg="white",cex=0.2)
dev.off()
#####


langs$Name_in_Tree = gsub("_","",langs$Name)
t = read.nexus("../data/Sagart_etal_2019/sinotibetan-beast-covarion-relaxed-fbd.mcct.trees")
t$tip.label = paste(t$tip.label,langs[match(t$tip.label,langs$Name_in_Tree),]$Glottocode)
pdf('../results/SagartTree.pdf',height=30,width=20)
par(mar=c(3,0,2,8))
plot(t, show.tip.label = F)#T, tip.color = 1+(t$tip.label %in% tLangs$glotto))
tiplabels(t$tip.label,adj=0,xpd=T)
dev.off()


# Tibetan_Lhasa utsa1239
# Tshangla/ Motuo_Menba  tsha1245
# Old_Tibetan clas1254


