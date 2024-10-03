setwd("~/OneDrive - Cardiff University/Funding/InternationalStrategicFund/project/processing/")

includeSagartLangs = TRUE

if(includeSagartLangs){
  destinationFile = "../data/BEAST/JMLwithSagartCombined_SinglePartition.nex"
  partitionFolder = "../data/BEAST/partitions/JMLwithSagartCombined/"
  d = read.csv("../data/JML_Cognate_Coding/JML_withSagart_combined2.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F)
} else{
  destinationFile = "../data/BEAST/JML_SinglePartition.nex"
  partitionFolder = "../data/BEAST/partitions/JML/"
  d = read.csv("../data/JML_Cognate_Coding/dhakalsouthwesttibetic 2/dhakalsouthwesttibetic.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F) 
}
d = d[d$NOTE!="[ignore]",]
d = d[d$NOTE!="[!] variant, can be excluded",]
d = d[d$NOTE!="[!] borrowing from Nepali",]
d = d[d$NOTE!="[borrowed from Chinese]",]
d = d[d$NOTE!="!remove!",]
#d = d[d$CONCEPT!="*To plough",]

#d$CONCEPT = gsub("\\(.+\\)","",d$CONCEPT)
d$CONCEPT = trimws(d$CONCEPT)

################
# FINAL CHOICE #
################
#outgroupLanguage = "S_Old_Chinese"
#toIncludeFromSagart = c()

# Filter languages
#d = d[(d$SOURCE=="") | (d$DOCULECT %in% toIncludeFromSagart),]

# Filter non-sorted cognates
#d = d[d$COGID!=100000,]

# Filter concepts with no variation
cogsPerConcept = tapply(d$COGID,d$CONCEPT,function(X){length(unique(X))})
conceptsWithNoVariation = names(cogsPerConcept)[cogsPerConcept==1]
d = d[!(d$CONCEPT %in% conceptsWithNoVariation),]

# Filter concepts that may be borrowings:
borrowings = c("NAME")
d = d[!d$CONCEPT %in% borrowings,]

# Filter concepts that are compounds (see Sagart SI page 15)
#compounds = c("Noon","FIREWOOD")
#d = d[!(d$CONCEPT %in% compounds),]

# Filter Concepts for which we only have data for our languages
#sourcesPerConcept = tapply(d$SOURCE,d$CONCEPT,function(X){length(unique(X))})
#conceptsWithOnlyOurData = names(sourcesPerConcept)[sourcesPerConcept==1]
# Concepts for our data with maximum variation
#dx = d[d$CONCEPT %in% conceptsWithOnlyOurData,]
#sort(tapply(dx$COGID,dx$CONCEPT,function(X){length(unique(X))}))
#keepMaxVarConcepts = c("GO","WHOLE","SPEAK","MORTAR CRUSHER","BREAD","RICE","COW")
#conceptsWithOnlyOurData = conceptsWithOnlyOurData[!(conceptsWithOnlyOurData %in% keepMaxVarConcepts)]
#d = d[!(d$CONCEPT %in% conceptsWithOnlyOurData),]


# Check concept coverage
# Sagart: "we made sure that all languages have translations for at least 85% of the concepts in our questionnaire"
numConceptsPerLang = sort(tapply(d$CONCEPT,d$DOCULECT,function(X){length(unique(X))}))
conceptCoverage = numConceptsPerLang/length(unique(d$CONCEPT))
conceptCoverage
all(conceptCoverage>=0.85)

# Check HORSE is still in data:
"Horse" %in% d$CONCEPT
"Pig" %in% d$CONCEPT
"Cow" %in% d$CONCEPT
"Rice" %in% d$CONCEPT
"Barley" %in% d$CONCEPT
"Wheat" %in% d$CONCEPT

# Check cogids aren't shared across concepts
conceptsPerCognate = tapply(d$CONCEPT,d$COGID,function(X){length(unique(X))})
all(conceptsPerCognate==1)

langsPerConcept = tapply(d$DOCULECT,d$CONCEPT,function(X){length(unique(X))})


########
# Stats

length(unique(d$CONCEPT))
length(unique(d$DOCULECT))
length(unique(paste(d$CONCEPT,d$COGID)))
range(tapply(d$COGID,d$CONCEPT,function(X){length(unique(X))}))
mean(tapply(d$COGID,d$CONCEPT,function(X){length(unique(X))}))
hist(tapply(d$COGID,d$CONCEPT,function(X){length(unique(X))}))
# Number of cases where a language has more than one cognate set per concept


#######
# Make Beast XML files for each concept
# Note this adds the Ascertainment Correction


nexus_template = 
  '#NEXUS

BEGIN TAXA;
TITLE Taxa;
DIMENSIONS NTAX=ntax_here;
TAXLABELS
taxlabels_here
;
END;

BEGIN CHARACTERS;
TITLE  Character_Matrix;
LINK TAXA = Taxa;
DIMENSIONS  NCHAR=nchar_here;
FORMAT DATATYPE=STANDARD GAP=- MISSING=? SYMBOLS="01";
MATRIX
characterData_here
;
'

makeNexusFile = function(taxlabels, characterData, filename){
  # make tax labels string
  taxlabels.string = paste(taxlabels,collapse='\n')
  # Get number of taxa
  numTax = length(taxlabels)
  # Get number of characters (variables)
  numChar = ncol(characterData)
  # add taxon labels to character section
  characterData.withNames = cbind(taxlabels,characterData)
  # paste everything together
  combineRows = apply(characterData.withNames,1, paste, collapse=' ')
  characterDatastring = paste(combineRows,collapse='\n')
  # Copy the template
  nex = nexus_template
  # add data to template by replacing markers
  nex = gsub("ntax_here", numTax, nex)
  nex = gsub("nchar_here", numChar, nex)
  nex = gsub("taxlabels_here", taxlabels.string, nex)
  nex = gsub("characterData_here", characterDatastring, nex)
  # write to file
  cat(nex, file=filename)
}

####################
# Single partition
taxa = sort(unique(d$DOCULECT))
taxaTreeNames = gsub("_","",taxa)
d = d[order(d$CONCEPT,d$COGID,d$DOCULECT),]
cogs = unique(d$COGID)
# Map of cogids to concepts
concepts = d[match(cogs,d$COGID),]$CONCEPT
rows = sapply(taxa, function(tax){
  row = 0 + cogs %in% d[d$DOCULECT==tax,]$COGID
  # Check for missing data (no concept matching the cog's concept)
  langHasNoData = !(concepts %in% d[d$DOCULECT==tax,]$CONCEPT)
  row[langHasNoData] = "?"
  return(row)
})
rows = t(rows)
# Double check there are no empty columns:
# (some columns have all 1s, which might also be removed?)
table(apply(rows,2,function(X){sum(X[X!="?"]=="1")}))
# ADD Ascertainment Correction
rows = cbind(rep(0,nrow(rows)),rows)

partColNames = c("AscertainmentCorrection",paste0(concepts,".",cogs))
partColNames = gsub(" ","",partColNames)
partColNames = gsub("[\\(\\)]","",partColNames)

colnames(rows) = partColNames
#write.csv("../data/BEAST/Tibetan_")

nexSingle = makeNexusFile(taxaTreeNames,rows,destinationFile)


########################
# Multiple Partitions
partitions = unique(d$CONCEPT)
taxa = sort(unique(d$DOCULECT))
taxaTreeNames = gsub("_","",taxa)

for(part in partitions){
  dx = d[d$CONCEPT==part,]
  cogs = unique(dx$COGID)
  taxaWithoutData = !(taxa %in% dx$DOCULECT)
  mat = sapply(cogs,function(cog){
    out = 0 + (taxa %in% dx[dx$COGID==cog,]$DOCULECT)
    out[taxaWithoutData] = "?"
    out
  })
  # Add Ascertainment Correction
  mat  = cbind(rep(0,nrow(mat)),mat)
  # Make nexus for partition
  partFileName = gsub(" ","-",part)
  partFileName = gsub("[\\(\\)]","",partFileName)
  partFileName = gsub("\\-+","-",partFileName)
  partFileName = gsub("-$","",partFileName)
  partFileName = gsub("/","_",partFileName)
  nex = makeNexusFile(taxaTreeNames,mat,paste0(partitionFolder,partFileName,".nex"))
  
}
