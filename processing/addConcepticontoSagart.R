try(setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/"))
d = read.csv("../data/Sagart_etal_2019/sino-tibetan-cleaned.tsv",stringsAsFactors = F,sep="\t",fileEncoding = "UTF-8",encoding = "UTF-8",quote='')

primary = "CONCEPT"
secondary = "GLOSS_IN_SOURCE"

d = d[d$ID!="#",]
d$GLOSS = d[,primary]
d$GLOSS[d[,primary]==""] = d[,secondary][d[,primary]==""]

d = d[d$GLOSS!="",]

d[d$CONCEPT=="cold (of temperature)",]$GLOSS = "COLD"

write.table(d,"../data/Sagart_etal_2019/sino-tibetan-cleaned2.tsv",sep="\t",quote = F, fileEncoding = "UTF-8", row.names = F)

# Run following command line:
# concepticon map_concepts sino-tibetan-cleaned2.tsv > sino-tibetan-cleaned-concepticon.tsv


d = read.csv("../data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon.tsv",stringsAsFactors = F,sep="\t",fileEncoding = "UTF-8",encoding = "UTF-8",quote='')

d = d[!is.na(d$CONCEPTICON_GLOSS),]
d = d[!grepl("^#",d$ID),]

takeOut = c("DRY UP","HE OR SHE OR IT",'TALL',"HOT OR WARM","CORRECT (RIGHT)","RIGHT HAND","HAIR (BODY)","LEAF (LEAFLIKE OBJECT)","MALE PERSON","SHIT (DEFECATE)","DENSE","YOUNG (OF MAN)","COLD (OF WEATHER)")

d = d[!d$CONCEPTICON_GLOSS %in% takeOut,]

d = d[!(d$CONCEPTICON_GLOSS=='COUNT' & d$CONCEPT=="to cry (weep)"), ]
d = d[!(d$CONCEPTICON_GLOSS=='HIDE' & d$CONCEPT=="to hide (conceal)"), ]

write.table(d,"../data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon2.tsv",sep="\t",quote = F, fileEncoding = "UTF-8", row.names = F)

## Merge

dhakal = read.delim("../data/processed/240WordList/AllLangs_240.qlc",stringsAsFactors = F,quote="",encoding = "UTF-8",fileEncoding = "UTF-8")
sagart = read.delim("../data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon2.tsv",stringsAsFactors = F,quote="",encoding = "UTF-8",fileEncoding = "UTF-8")

sagart$ID = sagart$ID + 10000

dhakal$SOURCE = "NEW"
sagart$SOURCE = "OLD"

sagart$CONCEPT = sagart$CONCEPTICON_GLOSS
sagart$COUNTERPART = sagart$GLOSS_IN_SOURCE

# Fix IPA
keepIPA = c("a","á","à","ă","â","ǎ","ã","ā","ạ","æ","ǽ,ɐ","ɑ","b","c","C","ç","ɕ","d","ɖ","e","é","è","ĕ","ê,","ě","ẽ","ẹ","ḛ","\u1d07","ə","ɛ","ɘ","ɤ","f","g","ɢ","ɣ","h",",","ɦ","i","í","ì","ĭ","î","ǐ","ĩ","ī","ị","ḭ","ı",",","ɪ","ɨ","j","ɟ","k","l","ɬ","ɮ","m","ṁ","n",",","ñ",",","ṅ","ɴ","ɲ","ɳ","\u0235","ŋ","o","ó","ò","ŏ","ô","ǒ","õ","ø,",",","ō","œ","ɶ","ɔ","ɵ","p","q","r","ɹ","ɽ","ɾ","ɿ","ʁ","s",",",",","ʂ","ʃ","ʅ","t","ʈ","\u0236","u","ú","ù","û","ǔ","ũ","ū","ụ,",",","ṵ","ʉ","ɥ","ɯ","ʊ","v","ʋ","ʌ","w","x","y","ỹ","z",",",",","ʐ","ʑ","ʒ","ʔ","β","θ","χ")

sagart$TOKENS = sapply(sagart$TOKENS,function(word){
  #word = gsub("[⁰¹₁²₂³⁴⁵̵̣̇'\\[\\]@/ˈ←˞̟̺̩.̠̆́̍̊̄̂̃∼ːı̱̀~∼3]","",word)
  tokens = strsplit(word," ")[[1]]
  tokens = sapply(tokens,function(t){strsplit(t,"/")[[1]][1]})
  #tokens = tokens[!tokens %in% c("⁰","¹","₁","²","₂","³","⁴","⁵")]
  tokens = tokens[tokens %in% keepIPA]
  tokens[tokens=="C"] = "c"
  tokens[tokens=="ṅ"] = "n"
  tokens[tokens=="ṁ"] = "m"
  tokens[tokens=="ẹ"] = "e"
  return(paste(tokens,collapse = " "))
})
sagart$IPA = gsub(" ","",sagart$TOKENS)


dhakal$TOKENS = ""
dhakal$COGID = 0
new = sagart[c("ID",'DOCULECT',"CONCEPT","IPA","COUNTERPART","SOURCE","TOKENS","COGID")]
new$OLDCOG = new$COGID

new = new[nchar(new$IPA)>0,]

write.table(new,"../data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon3.tsv",sep="\t",quote = F, fileEncoding = "UTF-8", row.names = F)


new = rbind(dhakal,sagart[c("ID",'DOCULECT',"CONCEPT","IPA","COUNTERPART","SOURCE","TOKENS","COGID")])
new$OLDCOG = new$COGID

new = new[nchar(new$IPA)>0,]

write.table(new,"../data/Sagart_etal_2019/Dhakal_and_Sagart_data.tsv",sep="\t",quote = F, fileEncoding = "UTF-8", row.names = F)


# Now run processing/extendCognatesToSagart.py
# Writes to ../data/Sagart_etal_2019/Dhakal_and_Sagart_data_clustered.tsv

###
d = read.csv("../data/Sagart_etal_2019/Dhakal_and_Sagart_data_clustered.tsv",sep="\t",quote="",stringsAsFactors = F,encoding = "UTF-8",fileEncoding = "UTF-8", skip=3, comment.char = "#")

sel = d$CONCEPT==unique(d$CONCEPT)[7]
heatmap(table(d[sel,]$COGID,d[sel,]$OLDCOG))
res = rep(0,length(unique(d$CONCEPT)))
names(res) = unique(d$CONCEPT)
for(con in unique(d$CONCEPT)){
  sel = d$CONCEPT==con
  tx = (table(d[sel,]$COGID,d[sel,]$OLDCOG))
  res[con] = sum(apply(tx,1,function(X){sum(X>0)})==1)/nrow(tx)
}

