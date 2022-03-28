setwd("~/Documents/Funding/InternationalStrategicFund/project/processing/")

d = read.csv("../data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended_Checked4.tsv", sep="\t",comment.char = "#",encoding = "UTF-8",fileEncoding = "UTF-8",quote = "",stringsAsFactors = F)

################
# FINAL CHOICE #
################
outgroupLanguage = "S_Old_Chinese"
toIncludeFromSagart = c("S_Old_Tibetan","S_Tibetan_Batang","S_Tibetan_Xiahe","S_Tibetan_Lhasa","S_Tibetan_Alike",outgroupLanguage)

# Filter languages
d = d[(d$SOURCE=="") | (d$DOCULECT %in% toIncludeFromSagart),]

# Filter non-sorted cognates
d = d[d$COGID!=100000,]

# Filter concepts with no variation
cogsPerConcept = tapply(d$COGID,d$CONCEPT,function(X){length(unique(X))})
conceptsWithNoVariation = names(cogsPerConcept)[cogsPerConcept==1]
d = d[!(d$CONCEPT %in% conceptsWithNoVariation),]

# Filter concepts that may be borrowings:
borrowings = c("TOMATO")
d = d[!d$CONCEPT %in% borrowings,]

# Filter concepts that are compounds (see Sagart SI page 15)
compounds = c("NOON","FIREWOOD")
d = d[!(d$CONCEPT %in% compounds),]

# Filter Concepts for which we only have data for our languages
sourcesPerConcept = tapply(d$SOURCE,d$CONCEPT,function(X){length(unique(X))})
conceptsWithOnlyOurData = names(sourcesPerConcept)[sourcesPerConcept==1]
# Concepts for our data with maximum variation
dx = d[d$CONCEPT %in% conceptsWithOnlyOurData,]
#sort(tapply(dx$COGID,dx$CONCEPT,function(X){length(unique(X))}))
keepMaxVarConcepts = c("GO","WHOLE","SPEAK","MORTAR CRUSHER","BREAD","RICE","COW")
conceptsWithOnlyOurData = conceptsWithOnlyOurData[!(conceptsWithOnlyOurData %in% keepMaxVarConcepts)]
d = d[!(d$CONCEPT %in% conceptsWithOnlyOurData),]


# Check concept coverage
# Sagart: "we made sure that all languages have translations for at least 85% of the concepts in our questionnaire"
numConceptsPerLang = sort(tapply(d$CONCEPT,d$DOCULECT,function(X){length(unique(X))}))
conceptCoverage = numConceptsPerLang/length(unique(d$CONCEPT))
conceptCoverage
all(conceptCoverage>=0.85)

# Check HORSE is still in data:
"HORSE" %in% d$CONCEPT
"PIG" %in% d$CONCEPT
"COW" %in% d$CONCEPT
"RICE" %in% d$CONCEPT
"BARLEY" %in% d$CONCEPT
"WHEAT" %in% d$CONCEPT

# Check cogids aren't shared across concepts
conceptsPerCognate = tapply(d$CONCEPT,d$COGID,function(X){length(unique(X))})
all(conceptsPerCognate==1)

########
# Stats

length(unique(d$CONCEPT))
length(unique(d$DOCULECT))
length(unique(paste(d$CONCEPT,d$COGID)))
range(tapply(d$COGID,d$CONCEPT,function(X){length(unique(X))}))
mean(tapply(d$COGID,d$CONCEPT,function(X){length(unique(X))}))
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
destinationFile = "../data/BEAST/Tibetan_SinglePartition.nex"
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
partitionFolder = "../data/BEAST/partitions/v1/"

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
  nex = makeNexusFile(taxaTreeNames,mat,paste0(partitionFolder,partFileName,".nex"))
  
}
