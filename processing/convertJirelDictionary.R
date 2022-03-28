library(openxlsx)
library("rjson")
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

variant.choice = "Sikri"

d = read.table("../data/raw/Jirel/Jirel.tab",sep="\t",quote='',encoding = "utf-8",fileEncoding = "utf-8", header = T, fill = T, stringsAsFactors = F)

d$TRANSCRIPTION = d[,variant.choice]
d$GLOSS = d$English

d$English = gsub(" +"," ",d$English)
d[d$ExtraMeaning!="",]$English = d[d$ExtraMeaning!="",]$ExtraMeaning

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

concepts = sapply(d$English,findConcept)
d$CONCEPT = concepts[2,]
d$CONCEPTID = concepts[1,]

d$ID = d$SN
d$SEGMENTS = ""
d$COGID = ""
d$DOCULECT = paste("Jirel_",variant.choice,sep="")

d = d[,c("ID",	"DOCULECT",	"CONCEPT",	"CONCEPTID",	"TRANSCRIPTION",	"SEGMENTS",	"COGID",	"GLOSS")]

write.table(d,file = "../data/processed/Jirel.tsv",quote=F,sep="\t",row.names = F,fileEncoding = "utf-8")
write.xlsx(d,file = "../data/processed/Jirel.xlsx")
