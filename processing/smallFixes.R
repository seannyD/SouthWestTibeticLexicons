setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/")
d = read.csv("../data/corrected/AllLangs_240_lexstat_aligned_Oct13.txt",
             quote = "",sep="\t",header = T,encoding = "UTF-8",fileEncoding = "UTF-8",stringsAsFactors = F)


rep = list(
  c("d z",'dz'),
  c("t s",'ts'),
  c("d ʑ","dʑ"),
  c("t ɕ","tɕ"),
  c("ʈ ʂ","ʈʂ"),
  c("ɖ ʐ","ɖʐ"),
  c("^([ŋnm]) ([ɲljntʔkŋgɡɹmdzrɾɕpsbhɦwgʂɖɰxʈ])","\\1\\2")
)

for(r in rep){
  d$SEGMENTS = gsub(r[1],r[2],d$SEGMENTS)  
  d$TOKENS = gsub(r[1],r[2],d$TOKENS)  
  d$ALIGNMENT = gsub(r[1],r[2],d$ALIGNMENT)  
}

d$ALIGNMENT = gsub("^([ŋnm][ɲljntʔkŋgɡɹmdzrɾɕpsbhɦwgʂɖɰxʈ])","- \\1",d$ALIGNMENT)

d$CONCEPT[d$CONCEPT=="PALM TREE"] = "PALM OF HAND"


write.table(d,"../data/corrected/AllLangs_240_lexstat_aligned_Oct16.txt",quote = F,sep='\t',na = "",fileEncoding = "UTF-8",row.names = F,col.names = T)
