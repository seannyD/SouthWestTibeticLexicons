library("rjson")
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

d = read.delim("../data/raw/Nubri/Nubri_240.tab",sep="\t",stringsAsFactors = F,encoding = "UTF-8",fileEncoding = "UTF-8")

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

d$Gloss.in.English = gsub(" +$","",d$Gloss.in.English)
d$GLOSS = d$Gloss.in.English

d$TRANSCRIPTION = d$Nubri.Transcription

dCon = sapply(d$Gloss.in.English,findConcept)

d$CONCEPT = dCon[2,]
d$CONCEPTID = dCon[1,]


d$ID = d$S..N.
d$SEGMENTS = ""
d$COGID = ""
d$DOCULECT = "Nubri"
d$SCRIPT = d$Gloss.in.Nepali
d$TONE = d$Possible.Tone




d = d[,c("ID",	"DOCULECT",	"CONCEPT",	"CONCEPTID",	"TRANSCRIPTION",	"SEGMENTS",	"COGID",	"GLOSS",	"SCRIPT","TONE")]

write.table(d,
            file = "../data/processed/Nubri.tsv",
            quote=F,sep="\t",
            row.names = F,
            fileEncoding = "utf-8")