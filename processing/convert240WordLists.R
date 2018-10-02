library("rjson")
try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

concepticon = fromJSON(file ="../data/reference/concepticon_conceptset.json/conceptset.json")

snToConcepticon = read.delim(
  file="../data/reference/SN_to_CONCEPTICON.tab",
  sep="\t",quote="", stringsAsFactors = F)

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

splitMultipleWordsIntoSeparateRows = function(dx){
  if(sum(grepl("/",dx$TRANSCRIPTION))>0){
    multiWord = dx[grepl("/",dx$TRANSCRIPTION),]
    splitWords = lapply(1:nrow(multiWord),function(i){
      X = multiWord[i,]
      words = strsplit(X$TRANSCRIPTION,"/")[[1]]
      tones = strsplit(X$TONE,"/")[[1]]
      X = do.call("rbind", replicate(length(words), X, simplify = FALSE))
      X$TRANSCRIPTION = words
      if(length(tones)==nrow(X)){
        X$TONE = tones
      }
      return(X)
    })
    multiWord = do.call(rbind,splitWords)
    
    dx = dx[!grepl("/",dx$TRANSCRIPTION),]
    dx = rbind(dx,multiWord)
    dx = dx[order(dx$ID),]
    return(dx)
  }
  return(dx)
}


convert240WordList = function(inputFile,outputFile,doculect){

  d = read.delim(inputFile,
                 sep="\t",stringsAsFactors = F,
                 encoding = "UTF-8",fileEncoding = "UTF-8")
  
  d$Gloss.in.English = gsub(" +$","",d$Gloss.in.English)
  d$GLOSS = d$Gloss.in.English
  
  d$TRANSCRIPTION = d[,2]
  #d$TRANSCRIPTION = gsub(' ',"",d$TRANSCRIPTION)
  
  #dCon = sapply(d$Gloss.in.English,findConcept)
  #d$CONCEPT = dCon[2,]
  #d$CONCEPTID = dCon[1,]
  
  d$CONCEPT = snToConcepticon[
    match(d$S..N.,
          snToConcepticon$SN),]$CONCEPT
  d$CONCEPTID = snToConcepticon[
    match(d$S..N.,
          snToConcepticon$SN),]$CONCEPTID
  
  
  d$SN = d$S..N.
  d$ID = d$S..N.
  d$SEGMENTS = ""
  d$COGID = ""
  d$DOCULECT = doculect
  d$SCRIPT = d$Gloss.in.Nepali
  d$TONE = d$Possible.Tone

  
  d = d[,c("ID","SN",	"DOCULECT",	"CONCEPT",	"CONCEPTID",	"TRANSCRIPTION",	"SEGMENTS",	"COGID",	"GLOSS",	"SCRIPT","TONE")]
  
  d = splitMultipleWordsIntoSeparateRows(d)
  d$ID = 1:nrow(d)
  
  d$TRANSCRIPTION = gsub("\\[","",d$TRANSCRIPTION)
  d$TRANSCRIPTION = gsub("\\]","",d$TRANSCRIPTION)
  d$TRANSCRIPTION = gsub("\\(","",d$TRANSCRIPTION)
  d$TRANSCRIPTION = gsub("\\)","",d$TRANSCRIPTION)
  
  d = d[nchar(d$TRANSCRIPTION)>0,]
  
  write.table(d,
              file = outputFile,
              quote=F,sep="\t",
              row.names = F,
              fileEncoding = "utf-8")
}


langs = c("Gyalsumdo","Jirel","Kagate","Lowa","Nubri",'Sherpa','Tsum',"Yolmo")

for(lang in langs){
  convert240WordList(
    paste0("../data/raw/",lang,"/",lang,"_240.tab"),
    paste0("../data/processed/240WordList/",lang,"_240.tab"),
    lang)
}

allLangs = data.frame()

for(lang in langs){
  d = read.delim(paste0("../data/processed/240WordList/",lang,"_240.tab"),
                 sep="\t",stringsAsFactors = F,
                 encoding = "UTF-8",fileEncoding = "UTF-8")
  allLangs = rbind(allLangs,d)
}

allLangs$COUNTERPART = paste0(allLangs$GLOSS,":",allLangs$TONE)

allLangs = allLangs[,!names(allLangs) %in% c("SN","SCRIPT","SEGMENTS","COGID","CONCEPTID","TONE","GLOSS")]

allLangs$ID = 1:nrow(allLangs)
names(allLangs)[names(allLangs)=="TRANSCRIPTION"] = "IPA"

write.table(allLangs,
            file = "../data/processed/240WordList/AllLangs_240.qlc",
            quote=F,sep="\t",
            row.names = F,
            fileEncoding = "utf-8")
