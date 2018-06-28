library(openxlsx)
library("rjson")
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

varieties = c('Namrung','Lhi','Lho','Sho','Sama')

dall = read.table("../data/raw/Nubri/Nubri_210.tab",sep="\t",quote='',encoding = "utf-8",fileEncoding = "utf-8", header = T, fill = T, stringsAsFactors = F)

concepticon = fromJSON(file ="../data/reference/concepticon_conceptset.json/conceptset.json")

concepticon$conceptset_labels[["arm/ hand"]] = c("1673","ARM")
#concepticon[[length(concepticon)+1]] = c("695","GO")
concepticon$conceptset_labels[["to speak/ speak"]] = c("1623","SPEAK")
concepticon$conceptset_labels[["to hear/listen"]] = c("1608","LISTEN")

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

for(variant.choice in varieties){
  d = dall
  d$TRANSCRIPTION = d[,variant.choice]
  d$GLOSS = d$English
  d$GLOSSNEPALI = d$Nepali
  d$ORTHOGRAPHIC = d$SN.
  d$English = gsub(" +"," ",d$English)
  d$English = gsub(" /","",d$English)
  
  concepts = sapply(d$English,findConcept)
  d$CONCEPT = concepts[2,]
  d$CONCEPTID = concepts[1,]
  
  # Fix plural "THIS"
  d[d$GLOSS=="these",]$CONCEPT = ""
  d[d$GLOSS=="those",]$CONCEPT = ""
  d[d$GLOSS=="these",]$CONCEPTID = ""
  d[d$GLOSS=="those",]$CONCEPTID = ""
  
  d$ID = 1:nrow(d)
  d$SEGMENTS = ""
  d$COGID = ""
  d$DOCULECT = paste("Nubri_",variant.choice,sep="")
  
  d = d[d$TRANSCRIPTION!="-",]
  
  d = d[,c("ID",	"DOCULECT",	"CONCEPT",	"CONCEPTID",	"TRANSCRIPTION",	"SEGMENTS",	"COGID",	"GLOSS","GLOSSNEPALI","ORTHOGRAPHIC")]
  
  write.table(d,file = 
                paste0("../data/processed/Nubri_",variant.choice,".tsv"),
                quote=F,sep="\t",
              row.names = F,fileEncoding = "utf-8")
  write.xlsx(d,file = paste0("../data/processed/Nubri_",variant.choice,".xlsx"))
}