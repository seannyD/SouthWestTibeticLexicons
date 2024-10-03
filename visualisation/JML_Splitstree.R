library(phangorn)
library(stringr)

try(setwd("~/OneDrive - Cardiff University/Funding/InternationalStrategicFund/project/visualisation/"))


#d = read.csv("../data/JML_Cognate_Coding/dhakalsouthwesttibetic 2/dhakalsouthwesttibetic.tsv",
d = read.csv("../data/JML_Cognate_Coding/JML_withSagart_combined.tsv",
             sep="\t",fileEncoding = "UTF-8",encoding = "UTF-8",comment.char = "#")
d = d[d$NOTE!="[ignore]",]
d = d[d$NOTE!="[!] variant, can be excluded",]
d = d[d$NOTE!="[!] borrowing from Nepali",]
d = d[d$NOTE!="[borrowed from Chinese]",]
d = d[d$NOTE!="!remove!",]

d = d[!d$DOCULECT %in% c("OldChinese","OldTibetan"),]

length(unique(d$CONCEPT))
allConcepts = unique(d$CONCEPT)

langs = unique(d$DOCULECT)

# Filter concepts that aren't present for all doculects
fullConcepts = tapply(d$DOCULECT,d$CONCEPT, 
                            function(X){length((unique(X)))==length(langs)})
d = d[d$CONCEPT %in% names(fullConcepts)[fullConcepts],]
length(unique(d$CONCEPT))

# Filter concepts with no variation
conceptsWithVar = tapply(d$COGID,d$CONCEPT,
       function(X){length(unique(X))>1})
d = d[d$CONCEPT %in% names(conceptsWithVar)[conceptsWithVar],]
length(unique(d$CONCEPT))

finalConcepts = unique(d$CONCEPT)

dists = sapply(unique(d$CONCEPT), function(concept){
  dx = d[d$CONCEPT==concept,]
  # Make sure there's only one item per cog/doculect
  dx = dx[!duplicated(dx[,c("COGID","DOCULECT")]),]
  tx = table(dx$COGID,dx$DOCULECT)
  distX = Reduce('+', apply(tx,1,dist,simplify = F))
  distX = distX/max(distX)
},simplify = F)

dists = Reduce("+", dists)

nnet <- neighborNet(dists)
pdf("../results/distances/JML_NeighbourNet.pdf",width=8,height=8)
plot(nnet)
dev.off()

# Alt method, just looking at overlap in cognates, 
# without weighting by concept
dx = d[!duplicated(d[,c("COGID","DOCULECT")]),]
dist2 = dist(table(dx$DOCULECT,dx$COGID))
nnet2 <- neighborNet(dist2)
plot(nnet2)

pdf("../results/distances/JML_NeighbourNet_nonWeighted.pdf",width=8,height=8)
plot(nnet2)
dev.off()


# Use the more detailed morpheme coding

dists2 = sapply(unique(d$CONCEPT), function(concept){
  dx = d[d$CONCEPT==concept,]
  # Make sure there's only one item per cog/doculect
  dx = dx[!duplicated(dx[,c("COGID","DOCULECT")]),]
  # Split into subcogs by doculect
  #subcogs = strsplit(dx$COGIDS," ")
  subcogs = tapply(dx$COGIDS,dx$DOCULECT,function(X){unique(unlist(strsplit(X," ")))})
  mx = matrix(nrow=length(subcogs),ncol=length(subcogs))
  rownames(mx) = names(subcogs)
  colnames(mx) = names(subcogs)
  for(i in 1:length(subcogs)){
    for(j in 1:length(subcogs)){
      mx[i,j] = 1-(length(intersect(subcogs[[i]],subcogs[[j]]))/max(c(length(subcogs[[i]]),length(subcogs[[j]]))))
    }
  }
  if(sum(mx)>0){
    mx = mx/max(mx)
  }
  return(mx)
},simplify = F)

dists2 = Reduce("+", dists2)


nnet2 <- neighborNet(dists2)
pdf("../results/distances/JML_NeighbourNet_Morpheme.pdf",width=8,height=8)
plot(nnet2)
dev.off()


# m = matrix(nrow=length(langs),ncol=length(langs))
# rownames(m) = langs
# colnames(m) = langs
# for(i in langs){
#   dxi = unique(d[d$DOCULECT==i,]$COGID)
#   for(j in langs){
#     dxj = unique(d[d$DOCULECT==j,]$COGID)
#     m[i,j] = 1 - (length(intersect(dxi,dxj))/max(c(length(dxi),length(dxj))))
#   }
# }


# Find places where subcogs matter
coverage = data.frame()
for(concept in unique(d$CONCEPT)){
  dx = d[d$CONCEPT==concept,]
  subcogs = strsplit(dx$COGIDS," ")#tapply(dx$COGIDS,dx$DOCULECT,function(X){unique(unlist(strsplit(X," ")))})
  lx = length(unique(unlist(subcogs)))
  mx = matrix(0,nrow=lx,ncol=lx)
  rownames(mx) = unique(unlist(subcogs))
  colnames(mx) = unique(unlist(subcogs))
  for(wd in subcogs){
    for(cog1 in wd){
      for(cog2 in wd){
        if(cog1!=cog2){
          mx[cog1,cog2] = 1
          mx[cog2,cog1] = 1
        }
      }
    }
  }
  x = (sum(mx)/2)/ ((length(mx)-nrow(mx))/2)
  coverage = rbind(coverage,data.frame(
    concept = dx$CONCEPT[1],
    x = x
  ))
  if(any(rowSums(mx)>4)){
    print(mx)
    print(dx[order(dx$COGIDS),c("DOCULECT","CONCEPT","COGIDS","COGID","ALIGNMENT")])
  }
}
coverage[order(coverage$x),]

coverage = data.frame()
for(concept in unique(d$CONCEPT)){
  dx = d[d$CONCEPT==concept,]
  cx = strsplit(dx$COGIDS," ")
  subcogs = unique(unlist(cx))
  cogs = unique(dx$COGID)
  mx = matrix(0,nrow=length(subcogs),ncol=length(cogs))
  rownames(mx) = subcogs
  colnames(mx) = as.character(cogs)
  for(x in 1:length(cx)){
    for(y in cx[x]){
      mx[y,as.character(dx[x,]$COGID)] = 1
    }
  }
  x = (sum(mx)/2)/ ((length(mx)-nrow(mx))/2)
  coverage = rbind(coverage,data.frame(
    concept = dx$CONCEPT[1],
    x = x
  ))
  if(any(rowSums(mx)>4)){
    print(dx[order(dx$COGIDS),c("DOCULECT","CONCEPT","COGIDS","COGID","ALIGNMENT")])
  }
}
coverage[order(coverage$x),]

dx = d[d$CONCEPT=="Same",]
write.table(dx[order(dx$COGIDS),],"../results/Example_Same.csv",fileEncoding = "UTF-8",row.names = F,sep="\t",quote = F)


########
old = read.csv("../data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended_Checked4.tsv",sep="\t",fileEncoding = "UTF-8",encoding = "UTF-8",comment.char = "#")

old = old[old$DOCULECT %in% c("S_Old_Chinese", "S_Old_Tibetan"),]
old$CONCEPT = str_to_sentence(old$CONCEPT)
oc = unique(old$CONCEPT)
x = oc[! oc %in% allConcepts]
length(x)

conChanges = read.csv("../data/JML_Cognate_Coding/ConceptMapping.csv",stringsAsFactors = F)
conChanges = conChanges[conChanges$Orig!="",]
for(i in 1:nrow(conChanges)){
  targ = conChanges$JML[i]
  repl = conChanges$Orig[i]
  if(targ %in% old$CONCEPT){
    old[old$CONCEPT==targ,]$CONCEPT = repl
  }
}
oc = unique(old$CONCEPT)
x = oc[! oc %in% allConcepts]
length(x)
#write.csv(data.frame(x=x),file="../data/JML_Cognate_Coding/ConceptMapping.csv", row.names = F)

old = old[old$CONCEPT %in% finalConcepts,]
old$ID = 100000+old$ID
old$FORM = old$IPA
old$VALUE = old$IPA
old$MORPHEMES = ""
old$COGIDS = ""
old$NOTE = "From Sagart et al."
d = rbind(d, old[,names(d)])

write.table(d,file="../data/JML_Cognate_Coding/JML_withSagart.tsv",
          sep="\t",quote=F,row.names = F)

# find differenes



