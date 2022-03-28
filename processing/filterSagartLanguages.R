# filter Sagart entries for cognate IDs and concepts that don't appear in our data.
setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/")

d = read.csv("../data/processed/240WordList/AllLangs_240_CogID_Sagart.tsv",sep="\t",stringsAsFactors = F,encoding = "UTF-8",fileEncoding = "UTF-8",comment.char = "#")


keepCogs = unique(d[d$SOURCE!="OLD",]$COGID)
keepConcepts = unique(d[d$SOURCE!="OLD",]$CONCEPT)

d = d[d$COGID %in% keepCogs,]
d =d[d$CONCEPT %in% keepConcepts,]

#d$TOKENS[d$TOKENS==""] = d$SEGMENTS[d$TOKENS==""]

write.table(d,"../data/processed/240WordList/AllLangs_240_CogID_Sagart.tsv",sep="\t",quote = F,fileEncoding = "UTF-8",row.names = F)
