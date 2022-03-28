library(openxlsx)
library("rjson")
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

d = read.xlsx("../data/raw/Tsum/Tsum_dict.xlsx",sheet=4)
names(d) = c("TRANSCRIPTION","pos","GLOSS")

concepticon = fromJSON(file ="../data/reference/concepticon_conceptset.json/conceptset.json")

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

dCon = sapply(d$GLOSS,findConcept)

d$CONCEPT = dCon[2,]
d$CONCEPTID = dCon[1,]

d$ID = 1:nrow(d)
d$SEGMENTS = ""
d$COGID = ""
d$DOCULECT = "Tsum"

d = d[,c("ID",	"DOCULECT",	"CONCEPT",	"CONCEPTID",	"TRANSCRIPTION",	"SEGMENTS",	"COGID",	"GLOSS",	"pos")]

write.table(d,file = "../data/processed/Tsum.tsv",quote=F,sep="\t",row.names = F,fileEncoding = "utf-8")
write.xlsx(d,file = "../data/processed/Tsum.xlsx")
