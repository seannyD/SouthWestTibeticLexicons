setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/")


oldWords = read.csv("../data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon3.tsv",sep="\t",stringsAsFactors = F,encoding = "UTF-8",fileEncoding = "UTF-8")
oldL = read.csv("../data/Sagart_etal_2019/languages.csv",stringsAsFactors = F)
newWords = read.csv("../data/processed/240WordList/AllLangs_240.qlc",sep="\t",stringsAsFactors = F,encoding = "UTF-8",fileEncoding = "UTF-8")

d = oldWords[oldWords$CONCEPT %in% newWords$CONCEPT,]

d = read.csv("../data/processed/240WordList/AllLangs_240_CogID_Sagart.tsv",sep="\t",stringsAsFactors=F,skip=3)
cogs = d[d$COGID>100000,]$COGID-100000

dx = oldWords[oldWords$COGID %in% cogs,]

# Which langauges are implicated?
sort(table(dx$DOCULECT))


#S_langsToInclude= ["Tibetan_Xiahe","Tibetan_Alike","Old_Tibetan","Tibetan_Batang","Mikir","Tibetan_Lhasa"]
tibetan = c("kham1282","byan1241","rong1264","kham1282","tsha1245","utsa1239","kham1282","amdo1237","amdo1237","karb1241")

gyalronic = c("horp1240","japh1234","eree1240","situ1238")

oldWordsToAdd = oldWords$DOCULECT 

d = rbind(d, oldWords[oldWords])