setwd("~/Documents/Funding/InternationalStrategicFund/project/analysis/")
library(ape)

t = read.nexus("../results/BEAST/covarion_noTibetanPrior/Tibetan_SinglePartition_10k_MCCT_Mean.trees")

d = read.delim("../data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended_Checked4.tsv",sep="\t",quote="",stringsAsFactors = F, encoding="UTF-8",fileEncoding = "UTF-8")

d$treeName = gsub("_","",d$DOCULECT)
h = d[(d$treeName %in% t$tip.label) || d$COGID=="105488",]
h= h[h$CONCEPT=="HORSE",]

p =  d[(d$treeName %in% t$tip.label) || d$COGID=="105488",]
p= p[p$CONCEPT=="HORSE",]

r = d[d$CONCEPT=="RICE",]

w = d[d$CONCEPT =="WHEAT",]
t.tibetan = extract.clade(t, getMRCA(t,c("SOldTibetan","Lowa")))
w = w[w$treeName %in% t.tibetan$tip.label,]

wheat = tapply(w$COGID,w$treeName,head,n=1)
wheat = wheat[t.tibetan$tip.label]

cols = rainbow(length(unique(wheat)))[as.numeric(as.factor(wheat))]
plot(t.tibetan, label.offset = 0.05)
tiplabels(pch = 21, bg = cols, cex = 2)
legend(0,4,c("tV","ne"),fill = unique(cols))
