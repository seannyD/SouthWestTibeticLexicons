library(rjson)
library(stringdist)
library(openxlsx)
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

readTSV = function(f){
  read.table(f,quote = "",stringsAsFactors = F, encoding = 'utf-8',fileEncoding = 'utf-8',sep="\t", header = T)
}

concepticon = fromJSON(file ="../data/reference/concepticon_conceptset.json/conceptset.json")

languageFiles = c(
  tsum="../data/processed/Tsum.tsv",
  nubri="../data/processed/Nubri.tsv",
  nubri_namrung = "../data/processed/Nubri_Namrung.tsv",
  nubri_lhi = "../data/processed/Nubri_Lhi.tsv",
  nubri_lho = "../data/processed/Nubri_Lho.tsv",
  nubri_sama = "../data/processed/Nubri_Sama.tsv",
  nubri_sho = "../data/processed/Nubri_Sho.tsv",
  gyalsumdo = "../data/processed/Gyalsumdo.tsv",
  jirel = "../data/processed/Jirel.tsv",
  lowa = "../data/processed/Lowa.tsv",
  yolmo = "../data/processed/Yolmo.tsv",
  kagate = "../data/processed/Kagate.tsv")

# Load data

allData = list()
for(l in names(languageFiles)){
  allData[[l]] = readTSV(languageFiles[l])
}

# advancedMatch= F
# if(advancedMatch){
#   tsum = readTSV("../data/processed/Tsum_advancedMatch.tsv")
#   tsum[tsum$CONCEPT=="",]$CONCEPT = tsum[tsum$CONCEPT=="",]$CONCEPTICON_GLOSS
#   nubri = readTSV("../data/processed/Nubri_advancedMatch.tsv")
#   nubri[nubri$CONCEPT=="",]$CONCEPT = nubri[nubri$CONCEPT=="",]$CONCEPTICON_GLOSS
#   gyalsumdo = readTSV("../data/processed/Gyalsumdo_advancedMatch.tsv")
#   gyalsumdo[gyalsumdo$CONCEPT=="",]$CONCEPT = gyalsumdo[gyalsumdo$CONCEPT=="",]$CONCEPTICON_GLOSS
#   jirel = readTSV("../data/processed/Jirel_advancedMatch.tsv")
#   jirel[jirel$CONCEPT=="",]$CONCEPT = jirel[jirel$CONCEPT=="",]$CONCEPTICON_GLOSS
#   lowa = readTSV("../data/processed/Lowa_advancedMatch.tsv")
#   lowa[lowa$CONCEPT=="",]$CONCEPT = lowa[lowa$CONCEPT=="",]$CONCEPTICON_GLOSS
#   yolmo = readTSV("../data/processed/Yolmo_advancedMatch.tsv")
#   yolmo[yolmo$CONCEPT=="",]$CONCEPT = yolmo[yolmo$CONCEPT=="",]$CONCEPTICON_GLOSS
#   
# }


for(l in names(languageFiles)){
  write.xlsx(allData[[l]],file = 
               gsub("\\.tsv",".xlsx",languageFiles[l]))
}


# Calculate stats

swadesh100 = read.csv("../data/reference/Swadesh1964_100.csv",stringsAsFactors = F, encoding = "utf-8",fileEncoding = 'utf-8')

dunn207 = read.csv("../data/reference/Dun_2012_207.tab", stringsAsFactors = F, encoding = 'utf-8', fileEncoding = "utf-8", sep="\t",quote="")

#finalConceptList = unique(allData[["jirel"]]$CONCEPT)

finalConcepts = read.csv("../data/reference/finalWordList.csv",stringsAsFactors = F)

finalConceptList = unique(finalConcepts$CONCEPT)

stats = data.frame(
  language = names(languageFiles),
  numEntries = 
    sapply(allData,function(X){length(X$CONCEPT)}),
  numConceptsMatchedToConcepticon = 
    sapply(allData,function(X){length(unique(X$CONCEPT))}),
  numSwadesh100ConceptsMatchedToConcepticon = 
    sapply(allData,function(X){sum(unique(X$CONCEPT) %in% swadesh100$Parameter)}),
  numFinalWordListConceptsMatchedToConcepticon = 
    sapply(allData,function(X){sum(finalConceptList %in% unique(X$CONCEPT))})
)

stats$progress = paste0(round(100*(stats$numFinalWordListConceptsMatchedToConcepticon/length(finalConceptList)),0),"%")

write.xlsx(stats,"../data/processed/progress.xlsx")

# Find missing concepts
findMissingConcepts = function(d){
  missing = data.frame(
        DOCULECT = d$DOCULECT[1],
        CONCEPT = finalConceptList[!finalConceptList %in% d$CONCEPT])
  missing$CONCEPTID = sapply(concepticon$conceptset_labels[missing$CONCEPT],head,n=1)
  return(missing)
}

missing = data.frame()

for(l in names(allData)){
  if(l!="jirel"){
    missing = rbind(missing,
                    findMissingConcepts(allData[[l]]))
  }
}


write.csv(missing,file="../data/processed/MissingConcepts.csv", fileEncoding = 'utf-8')

########################
# Shallow network analysis
# TODO: refactor to use 

tsum = as.data.frame(allData[["tsum"]])
nubri = as.data.frame(allData[["nubri"]])
nubri_namrung = as.data.frame(allData[["nubri_namrung"]])
gyalsumdo = as.data.frame(allData[["gyalsumdo"]])
lowa = as.data.frame(allData[["lowa"]])
yolmo = as.data.frame(allData[["yolmo"]])
jirel = as.data.frame(allData[["jirel"]])
kagate = as.data.frame(allData[["kagate"]])

# Find some concepts that are common

allConcepts = unique(c(tsum$CONCEPT,nubri$CONCEPT,gyalsumdo$CONCEPT,kagate$CONCEPT,nubri$CONCEPT,nubri_namrung$CONCEPT))
allConcepts = allConcepts[allConcepts!=""]

overlapConceptsALL = allConcepts[allConcepts %in% tsum$CONCEPT &
                                   ((allConcepts %in% nubri$CONCEPT) | (allConcepts %in% nubri_namrung$CONCEPT)) &
                                   allConcepts %in% gyalsumdo$CONCEPT & allConcepts %in% lowa$CONCEPT & allConcepts %in% yolmo$CONCEPT & allConcepts %in% kagate$CONCEPT]

possibleExtraConcepts = overlapConceptsALL[!overlapConceptsALL %in% finalConceptList]
possibleExtraConcepts

numLangsCovered = sort(sapply(allConcepts,function(con){
  sum(sapply(allData,function(dx){
    con %in% dx$CONCEPT
  }))
}))

# Subset of langs

allConcepts = unique(c(tsum$CONCEPT,nubri$CONCEPT,gyalsumdo$CONCEPT))
allConcepts = allConcepts[allConcepts!=""]


overlapConcepts = allConcepts[allConcepts %in% tsum$CONCEPT & allConcepts %in% nubri$CONCEPT & allConcepts %in% gyalsumdo$CONCEPT & allConcepts %in% lowa$CONCEPT & allConcepts %in% yolmo$CONCEPT]

getOverlap = function(d){
  d = d[d$CONCEPT %in% overlapConcepts,]
  d = d[!duplicated(d$CONCEPT),]
  return(gsub(" +","",d[order(d$CONCEPT),]$TRANSCRIPTION))
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

