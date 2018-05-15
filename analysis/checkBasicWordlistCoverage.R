library(rjson)
library(stringdist)
library(openxlsx)
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

readTSV = function(f){
  read.table(f,quote = "",stringsAsFactors = F, encoding = 'utf-8',fileEncoding = 'utf-8',sep="\t", header = T)
}

concepticon = fromJSON(file ="../data/reference/concepticon_conceptset.json/conceptset.json")

# Load data
tsum = readTSV("../data/processed/Tsum.tsv")
#tsum = readTSV("../data/processed/Tsum_tmp.tsv")
#tsum = tsum[!duplicated(tsum$ID),]
#tsum$CONCEPT = tsum$CONCEPTICON_GLOSS
nubri = readTSV("../data/processed/Nubri.tsv")
gyalsumdo = readTSV("../data/processed/Gyalsumdo.tsv")
jirel = readTSV("../data/processed/Jirel.tsv")
lowa = readTSV("../data/processed/Lowa.tsv")
yolmo = readTSV("../data/processed/Yolmo.tsv")
kagate = readTSV("../data/processed/Kagate.tsv")

# Convert to xlsx
write.xlsx(tsum,file = "../data/processed/Tsum.xlsx")
write.xlsx(nubri,file = "../data/processed/Nubri.xlsx")
write.xlsx(gyalsumdo,file = "../data/processed/Gyalsumdo.xlsx")
write.xlsx(jirel,file = "../data/processed/Jirel.xlsx")
write.xlsx(lowa,file = "../data/processed/Lowa.xlsx")
write.xlsx(yolmo,file = "../data/processed/Yolmo.xlsx")
write.xlsx(kagate,file = "../data/processed/Kagate.xlsx")


# Calculate stats

swadesh100 = read.csv("../data/reference/Swadesh1964_100.csv",stringsAsFactors = F, encoding = "utf-8",fileEncoding = 'utf-8')

dunn207 = read.csv("../data/reference/Dun_2012_207.tab", stringsAsFactors = F, encoding = 'utf-8', fileEncoding = "utf-8", sep="\t",quote="")

jirelConcepts = unique(jirel$CONCEPT)

stats = data.frame(
  language = c("tsum",'nubri','gyalsumdo','jirel','lowa','yolmo','kagate'),
  numEntries = c(
    length((tsum$CONCEPT)),
    length((nubri$CONCEPT)),
    length((gyalsumdo$CONCEPT)),
    length((jirel$CONCEPT)),
    length((lowa$CONCEPT)),
    length((yolmo$CONCEPT)),
    length((kagate$CONCEPT))       
  ),
  numConceptsMatchedToConcepticon = c(
    length(unique(tsum$CONCEPT)),
    length(unique(nubri$CONCEPT)),
    length(unique(gyalsumdo$CONCEPT)),
    length(unique(jirel$CONCEPT)),
    length(unique(lowa$CONCEPT)),
    length(unique(yolmo$CONCEPT)),
    length(unique(kagate$CONCEPT))    
  ),
  numSwadesh100ConceptsMatchedToConcepticon = c(
    sum(unique(tsum$CONCEPT) %in% swadesh100$Parameter),
    sum(unique(nubri$CONCEPT) %in% swadesh100$Parameter),
    sum(unique(gyalsumdo$CONCEPT) %in% swadesh100$Parameter),
    sum(unique(jirel$CONCEPT) %in% swadesh100$Parameter),
    sum(unique(lowa$CONCEPT) %in% swadesh100$Parameter),
    sum(unique(yolmo$CONCEPT) %in% swadesh100$Parameter),
    sum(unique(kagate$CONCEPT) %in% swadesh100$Parameter)    
  ),
  numJirel208ConceptsMatchedToConcepticon = c(
    sum(jirelConcepts %in% unique(tsum$CONCEPT)),
    sum(jirelConcepts %in% unique(nubri$CONCEPT)),
    sum(jirelConcepts %in% unique(gyalsumdo$CONCEPT)),
    sum(jirelConcepts %in% unique(jirel$CONCEPT)),
    sum(jirelConcepts %in% unique(lowa$CONCEPT)),
    sum(jirelConcepts %in% unique(yolmo$CONCEPT)),
    sum(jirelConcepts %in% unique(kagate$CONCEPT))
  )
)

stats$progress = paste0(round(100*(stats$numJirel208ConceptsMatchedToConcepticon/length(jirelConcepts)),0),"%")

# Find missing concepts
findMissingConcepts = function(d){
  missing = data.frame(
        DOCULECT = d$DOCULECT[1],
        CONCEPT = jirelConcepts[!jirelConcepts %in% d$CONCEPT])
  missing$CONCEPTID = sapply(concepticon$conceptset_labels[missing$CONCEPT],head,n=1)
  return(missing)
}

missing = rbind(findMissingConcepts(tsum),
      findMissingConcepts(nubri),
      findMissingConcepts(gyalsumdo),
      #findMissingConcepts(jirel),
      findMissingConcepts(lowa),
      findMissingConcepts(yolmo),
      findMissingConcepts(kagate))

write.csv(missing,file="../data/processed/MissingConcepts.csv", fileEncoding = 'utf-8')


# Shallow network analysis

allConcepts = unique(c(tsum$CONCEPT,nubri$CONCEPT,gyalsumdo$CONCEPT))
allConcepts = allConcepts[allConcepts!=""]

overlapConcepts = allConcepts[allConcepts %in% tsum$CONCEPT & allConcepts %in% nubri$CONCEPT & allConcepts %in% gyalsumdo$CONCEPT & allConcepts %in% lowa$CONCEPT & allConcepts %in% yolmo$CONCEPT]

getOverlap = function(d){
  d = d[d$CONCEPT %in% overlapConcepts,]
  d = d[!duplicated(d$CONCEPT),]
  return(d[order(d$CONCEPT),]$TRANSCRIPTION)
}

compareIPA = function(l1,l2){
  dists = sapply(1:length(l1),function(i){
    stringdist(l1[i],l2[i],method = 'lv')/
      max(nchar(l1[i]),nchar(l2[i]))
  })
  mean(dists,na.rm=T)
}

overlapIPA = 
  list(getOverlap(tsum),
     getOverlap(nubri),
     getOverlap(gyalsumdo),
     getOverlap(jirel),
     getOverlap(lowa),
     getOverlap(yolmo),
     getOverlap(kagate))
names(overlapIPA) = c("tsum",'nubri','gyalsumdo','jirel','lowa','yolmo','kagate')

dists = matrix(0,nrow = length(overlapIPA),ncol = length(overlapIPA))
rownames(dists) = names(overlapIPA)
colnames(dists) = names(overlapIPA)

for(i in 1:length(overlapIPA)){
  for(j in i:length(overlapIPA)){
    dx = compareIPA(overlapIPA[[i]],overlapIPA[[j]])
    dists[names(overlapIPA)[i],names(overlapIPA)[j]] = dx
    dists[names(overlapIPA)[j],names(overlapIPA)[i]] = dx
  }
}

makeSplitstree = function(dists, filename){
  header = paste("#nexus\n\nBEGIN Taxa;\nDIMENSIONS ntax=",nrow(dists),";\nTAXLABELS\n",collapse="")
  
  taxlabels= paste(paste("[",1:nrow(dists),"] '",rownames(dists),"'",sep=''),collapse='\n')
  
  header2 = paste("\n;\nEND;  [TAXA]\n\nBEGIN DISTANCES;\n        DIMENSIONS NTAX=" , nrow(dists),";  FORMAT  TRIANGLE=BOTH DIAGONAL LABELS=LEFT;\nMATRIX\n", collapse='')
  
  rnames = paste("'",rownames(dists),"'",sep='')
  
  mat = paste(paste(rnames,apply(dists,1,paste,collapse=' ')),collapse='\n')
  
  header3 = "\n;\nEND;\n"
  
  nexus = paste(header, taxlabels, header2, mat, header3, collapse='')
  
  cat(nexus,file = filename)
}

makeSplitstree(dists,"../results/distances/distances.nex")

