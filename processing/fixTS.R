try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))

readTSV = function(f){
  read.table(f,quote = "",stringsAsFactors = F, encoding = 'utf-8',fileEncoding = 'utf-8',sep="\t", header = T)
}

d = readTSV("../data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended_Checked.tsv")

hasTS = grepl("t s",d$SEGMENTS)
ourLangs= unique(d[d$SOURCE=="",]$DOCULECT)

fixTS = function(X){
  #X = gsub("^t s","ts",X)
  #X = gsub("t s ","ts ",X)  
  X = gsub("t s","ts",X)  
  return(X)
}

d$SEGMENTS[d$DOCULECT %in% ourLangs] = fixTS(d$SEGMENTS[d$DOCULECT %in% ourLangs])
d$TOKENS[d$DOCULECT %in% ourLangs] = fixTS(d$TOKENS[d$DOCULECT %in% ourLangs])
d$ALIGNMENT[d$DOCULECT %in% ourLangs] = fixTS(d$ALIGNMENT[d$DOCULECT %in% ourLangs])
d$ALIGNMENT[d$DOCULECT %in% ourLangs] = gsub("t - s","ts",d$ALIGNMENT[d$DOCULECT %in% ourLangs])

keep = c("ID","X","ID.1","DOCULECT","CONCEPT","IPA","COUNTERPART","COGID","OLDCOG","SEGMENTS","SOURCE","TOKENS","ALIGNMENT")

write.table(d,file="../data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended_Checked2.tsv",sep="\t",quote = F,row.names = F,fileEncoding = "UTF-8")

