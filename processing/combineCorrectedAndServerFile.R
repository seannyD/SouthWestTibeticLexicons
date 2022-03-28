setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/")

options(scipen=99999999)

#  Combine corrected data with extended server file
#    	We can just match on ID, then copy over just the alignments?
#       So: Start with complete corrected, add in data from the cleaned sino tibetan file, then add alignments from server file
#       THEN: Filter for concepts that don't appear in our data
#         We'll still need to edit out characters that we don't want (tone, ◦, +, _)

d = read.delim("../data/corrected/AllLangs_240_CogID_Sagart_Complete.tsv",stringsAsFactors = F,encoding = "UTF-8",fileEncoding = "UTF-8")


got = unique(d[d$SOURCE=="OLD",]$CONCEPT)
need = unique(d$CONCEPT)
need = need[!need %in% got]


server = read.delim("../data/Sagart_etal_2019/sino-tibetan-FullServerDataWithAlignments.tsv",stringsAsFactors = F,encoding = "UTF-8",fileEncoding = "UTF-8", comment.char = "#")
#server = server[!grepl("^#",server$ID),]
server$CONCEPT = toupper(server$CON)

server$CONCEPT = gsub("THE ","",server$CONCEPT)
server$CONCEPT = gsub("TO ","",server$CONCEPT)
server$CONCEPT = gsub("TO ","",server$CONCEPT)
server$CONCEPT = gsub("","",server$CONCEPT)

replacements = read.delim("../data/Sagart_etal_2019/conceptMappings.tab",stringsAsFactors = F)
for(i in 1:nrow(replacements)){
  server$CONCEPT[server$CONCEPT==replacements[i,]$Sagart] = replacements[i,]$ourData
}

sum(unique(d$CONCEPT) %in% unique(server$CONCEPT))

# d$ID.1 maps to server ID + 10000
server$ID.1 = as.numeric(server$ID) +10000
server$ID = -999
server = server[!is.na(server$ID.1),]

server = server[!server$ID.1 %in% d$ID.1,]

server = server[server$CONCEPT %in% d$CONCEPT,]
server$COGID = server$COGID +100000

# clean entries

keepIPA = c("(",")","-","a","á","à","ă","â","ǎ","ã","ā","ạ","æ","ǽ,ɐ","ɑ","b","c","C","ç","ɕ","d","ɖ","e","é","è","ĕ","ê,","ě","ẽ","ẹ","ḛ","\u1d07","ə","ɛ","ɘ","ɤ","f","g","ɢ","ɣ","h",",","ɦ","i","í","ì","ĭ","î","ǐ","ĩ","ī","ị","ḭ","ı",",","ɪ","ɨ","j","ɟ","k","l","ɬ","ɮ","m","ṁ","n",",","ñ",",","ṅ","ɴ","ɲ","ɳ","\u0235","ŋ","o","ó","ò","ŏ","ô","ǒ","õ","ø,",",","ō","œ","ɶ","ɔ","ɵ","p","q","r","ɹ","ɽ","ɾ","ɿ","ʁ","s",",",",","ʂ","ʃ","ʅ","t","ʈ","\u0236","u","ú","ù","û","ǔ","ũ","ū","ụ,",",","ṵ","ʉ","ɥ","ɯ","ʊ","v","ʋ","ʌ","w","x","y","ỹ","z",",",",","ʐ","ʑ","ʒ","ʔ","β","θ","χ")

cleanWord = function(word,rep=""){
  #word = gsub("[⁰¹₁²₂³⁴⁵̵̣̇'\\[\\]@/ˈ←˞̟̺̩.̠̆́̍̊̄̂̃∼ːı̱̀~∼3]","",word)
  tokens = gsub("[⁰¹₁²₂³⁴⁵◦⁵²+~_]",rep,word)
  tokens = strsplit(tokens," ")[[1]]
  #tokens = sapply(tokens,function(t){strsplit(t,"/")[[1]][1]})
  #tokens = tokens[!tokens %in% c("⁰","¹","₁","²","₂","³","⁴","⁵")]
  #tokens = tokens[tokens %in% keepIPA]
  tokens[tokens=="C"] = "c"
  tokens[tokens=="ṅ"] = "n"
  tokens[tokens=="ṁ"] = "m"
  tokens[tokens=="ẹ"] = "e"
  if(rep==""){
    tokens = gsub(" ","",tokens)
  }
  return(paste(tokens,collapse = " "))
}

server$TOKENS = sapply(server$TOKENS,cleanWord)
server$TOKENS = gsub(" +"," ",server$TOKENS)
server$ALIGNMENT = sapply(server$ALIGNMENT,cleanWord,rep="-")
server$ALIGNMENT = gsub(" +"," ",server$ALIGNMENT)
server$ALIGNMENT = gsub("-+","-",server$ALIGNMENT)

server$X = NA
server$COUNTERPART = NA
server$SEGMENTS = server$TOKENS
server$SONARS = ""
server$PROSTRINGS = ""
server$CLASSES = ""
server$LANGID = 0
server$NUMBERS = ""
server$WEIGHTS = ""
server$DUPLICATES = ""
server$SOURCE = "OLD"
server$OLDCOG = server$COGID

server$DOCULECT = paste0("S_",server$DOCULECT)

server = server[!is.na(server$CONCEPT),]
server = server[server$CONCEPT!="",]

d = rbind(d,server[,names(d)])

d = d[order(d$CONCEPT,d$COGID, d$SOURCE,d$DOCULECT),]

missingID= d$ID<0
d$ID[missingID] = max(d$ID)+1:length(d$ID[missingID])

d = d[!is.na(d$DOCULECT),]

write.table(d,file="../data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended.tsv",sep="\t",quote = F,row.names = F,fileEncoding = "UTF-8")
