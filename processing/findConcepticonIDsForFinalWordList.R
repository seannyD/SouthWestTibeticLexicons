library(openxlsx)
library("rjson")
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

d = read.table("../data/reference/finalWordList.tab",sep="\t",quote='',encoding = "utf-8",fileEncoding = "utf-8", header = T, fill = T, stringsAsFactors = F)

d$GLOSS = gsub(" +"," ",d$GLOSS)

concepticon = fromJSON(file ="../data/reference/concepticon_conceptset.json/conceptset.json")

concepticonGloss = sapply(concepticon$conceptset_labels,function(X){c(X[1],X[2])})

findConcept = function(gloss){
  gloss2 = gsub("$ +","",gloss)
  gloss2 = gsub(" +^","",gloss)
  gloss2 = tolower(gloss2)
  if(gloss2 %in% names(concepticon$conceptset_labels)){
    return(concepticon$conceptset_labels[[gloss2]])
  }
  if(gloss2 %in% names(concepticon$alternative_labels)){
    return(concepticon$alternative_labels[[gloss2]])
  }
  return(c("",""))
}

concepts = sapply(d$GLOSS,findConcept)
d$CONCEPT = concepts[2,]
d$CONCEPTID = concepts[1,]

d[d$CONCEPT=="",]$GLOSS

extra = c("arm/ hand"=1673,
  "wheat(husked)"=1077,
  "to give " = 1447,    
  "to kill " = 1417,             
  "to walk " = 1443,
  "to run/ run" = 1519,
  "to go /go" = 695,         
  "to speak/ speak" =1623,
  "to hear/hear/listen" = 1608,
  "to look/look"   =1819,     
  "flour (eaten as food)" =1594,
  "hailstone"  =609, 
  "to uproot" = 9991,            
  "bond" = 1917,                    
  "beam (main wooden beam)" =1132	,
  "rope used to tie animals" = 1218	,
  "plank" = 1227, 
  "plough (noun)" = 2154,         
  "lid (cover)" =2319,           
  "manure" = 2057,               
  "grains" = 605)

d$CONCEPTID[match(names(extra),d$GLOSS)] = extra
d$CONCEPT[match(names(extra),d$GLOSS)] = concepticonGloss[2,match(as.character(extra),concepticonGloss[1,])]

d[is.na(d$CONCEPT),]$CONCEPT = ""

write.csv(d,"../data/reference/finalWordList.csv",row.names = F)
