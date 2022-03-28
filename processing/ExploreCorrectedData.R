library(ape)
library(phytools)
library(phangorn)
setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/")

# Old code pre-server file
# orig = read.csv("../data/processed/240WordList/AllLangs_240_CogID_Sagart.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F)
# 
# sagart = read.csv("../data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon3.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F)
# 
# sLangFreq = table(sagart$DOCULECT)
# 
# d = read.csv("../data/corrected/AllLangs_240_CogID_Sagart_Complete.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F)
# 
# # Check we're not missing rows
# nrow(d)==nrow(orig)
# 
# # Check each cog only maps to one concept
# conceptsPerCog = tapply(d$CONCEPT,d$COGID,function(X){length(unique(X))})
# conceptsPerCog[conceptsPerCog>1]
# 

#
d = read.csv("../data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended_Checked4.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F)


########

# Draw neighbournet
dx = d#[d$SOURCE!="OLD",]
# Choose only concepts that appear in both datasets
cx = tapply(d$SOURCE,d$CONCEPT,function(X){length(unique(X))})
sum(cx>1)
dx = dx[dx$CONCEPT %in% names(cx)[cx==2],]

# Choose langs with enough concepts
# Sagart: "we made sure that all languages have translations for at least 85% of the concepts in our questionnaire"
numConceptsPerLang = sort(tapply(dx$CONCEPT,dx$DOCULECT,function(X){length(unique(X))}))
numConceptsPerLang/max(numConceptsPerLang)

dxChosenLanguages = names(numConceptsPerLang)[(numConceptsPerLang/max(numConceptsPerLang))>=0.85]

dx = dx[dx$DOCULECT %in% dxChosenLanguages,]

# Check number of languages per concept
langsPerConcept = sort(tapply(dx$DOCULECT,dx$CONCEPT,function(X){length(unique(X))}))
hist(langsPerConcept)
chosenConcepts = names(langsPerConcept)[langsPerConcept>=25]
dx = dx[dx$CONCEPT %in% chosenConcepts,]

# Selection:
toIncludeFromSagart = c("S_Old_Tibetan","S_Tibetan_Batang","S_Tibetan_Xiahe","S_Tibetan_Lhasa","S_Tibetan_Alike","S_Old_Chinese")

# Take out concepts with no variation

# Check all langs have >=85% of concepts:
numConceptsPerLang2 = sort(tapply(dx$CONCEPT,dx$DOCULECT,function(X){length(unique(X))}))
all((numConceptsPerLang2/max(numConceptsPerLang2))>=0.85)

# Make distance matrix
m = matrix(nrow=length(dxChosenLanguages),ncol=length(dxChosenLanguages))
rownames(m) = dxChosenLanguages
colnames(m) = dxChosenLanguages
for(i in dxChosenLanguages){
  dxi = unique(dx[dx$DOCULECT==i,]$COGID)
  for(j in dxChosenLanguages){
    dxj = unique(dx[dx$DOCULECT==j,]$COGID)
    m[i,j] = 1 - (length(intersect(dxi,dxj))/max(c(length(dxi),length(dxj))))
  }
}
nn = neighborNet(as.dist(m))
pdf("../results/distances/NeighbourNet.pdf",width=30,height=30)
plot(nn,type="2D")
dev.off()

##
# How much data are we missing if we just look at overlapping concepts?
dx = d[d$SOURCE!="OLD",]
# Choose only non overlapping concepts
dx = dx[!dx$CONCEPT %in% d[d$SOURCE=="OLD",]$CONCEPT,]
table(tapply(dx$COGID,dx$CONCEPT,function(X){length(unique(X))}))
# 63 concepts have no information, 90 concepts will be lost


# Which languages should we include from Sagart?
# Find coverage of cognates in our data:
oldCogs = unique(d[d$SOURCE!="OLD",]$COGID)
oldCogs = oldCogs[oldCogs>=100000]
oldCogs = oldCogs - 100000

sCogLangs = d[d$COGID %in% oldCogs,]
sCogLangFreq = table(sCogLangs$DOCULECT)
sort(sCogLangFreq)
sCogLangProp = sCogLangFreq / sLangFreq[names(sCogLangFreq)]
sort(sCogLangProp)

plot(sort(sCogLangProp),type='l')

# Coverage is good for:
goodCoverage = c("Old_Tibetan","Tibetan_Batang","Tibetan_Xiahe","Tibetan_Lhasa","Tibetan_Alike")

# Plot tree:
sLangs =  read.csv("../data/Sagart_etal_2019/languages.csv",stringsAsFactors = F)
tLangs = read.csv("../data/languages_to_glotto.tab",stringsAsFactors = F, sep="\t",quote='')
g = read.csv("../../../../Bristol/word2vec/word2vec_DPLACE/data/glottolog-languoid.csv/languoid.csv",stringsAsFactors = F)
tLangs$lat = g[match(tLangs$glotto,g$id),]$latitude
tLangs$long = g[match(tLangs$glotto,g$id),]$longitude

sLangs$Name_in_Tree = gsub("_","",sLangs$Name)
sTree = read.nexus("../data/Sagart_etal_2019/sinotibetan-beast-covarion-relaxed-fbd.mcct.trees")

goodCoverageTreeName = sLangs[match(goodCoverage,sLangs$Name),]$Name_in_Tree
goodCoverageTreeName[goodCoverage=="Old_Tibetan"] = "TibetanOldTibetan"

sCogLangPropX = matrix(c(sCogLangProp,1-(sCogLangProp)),ncol=2)
rownames(sCogLangPropX)= names(sCogLangProp)

pdf("../data/corrected/CogCoverage.pdf",height=30,width=20)
par(mar=c(3,0,2,8))
plot(sTree, show.tip.label = F,xpd=T)#T, tip.color = 1+(t$tip.label %in% tLangs$glotto))
tiplabels(sTree$tip.label,adj=0,bg=NA,xpd=T,frame = "none",offset = 0.2)
#include = sTree$tip.label %in% goodCoverageTreeName
#tiplabels(sTree$tip.label[include],which(include),adj=0,xpd=T)
tiplabels(round(sCogLangProp[sTree$tip.label],2),pie=sCogLangPropX[sTree$tip.label,],piecol = c("red",NA))
dev.off()


###
#Plot locations on a map
library(maps)
map(xlim = c(75.64,90.47),ylim=c(25.34,32.94))
#points(sLangs$Longitude,sLangs$Latitude)
text(sLangs$Longitude,sLangs$Latitude,labels = sLangs$Number,col=1:6)
points(tLangs$long,tLangs$lat,col=2)

sLangs[sLangs$Number %in% c(11,18,3,23),]$Name
sLangs[sLangs$Number %in% c(4,22,39,25),]$Name

###
tibetanTree = extract.clade(sTree, 67)
plot(tibetanTree)

toInclude = c("TibetanOldTibetan","TibetanBatang","TibetanXiahe","TibetanLhasa","TibetanAlike","QiangicZhaba","rGyalrongMaerkang","rGyalrongJaphug",'Tangut',"rGyalrongDaofu","KhroskyabsWobzi")
iTree = drop.tip(sTree,sTree$tip.label[!sTree$tip.label %in% toInclude])
plot(iTree)
