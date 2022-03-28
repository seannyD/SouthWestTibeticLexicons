# Takes the old list (Sagart) and a new list (new tibetan data) and tries to assign cognate classes from the old list to the new list.

from lingpy import *
import itertools
import re


scoringRuns = 10000
scaModel = Model("sca")
gap_penalty = scaModel.scorer.matrix[scaModel.scorer.chars2int["_"]][0]

oldWords = Wordlist("../data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon3.tsv")
newWords = Wordlist("../data/processed/240WordList/AllLangs_240.qlc")
# Add COGID to newWords data
newWords.add_entries('COGID','IPA',lambda x:0)

def toTokens(s):
	tokens = ipa2tokens(s)
	classes = tokens2class(tokens,"sca")
	return(classes)
	
def getAllKeys(l):
	l = list(itertools.chain.from_iterable(l))
	l = [x for x in l if x!=0]
	return(l)
	
def cleanS(s):
	s = [re.sub("[¹²³⁴⁵₁₂\+_]","",x) for x in s]
	s = [x for x in s if len(x)>0]
	return(s)
	
#def getAlignmentScore(classesA,classesB):
#	return(edit_dist(sClasses,dClasses, normalized=True))

def getMinimumNWScore(classes):
    # based on the empty string
    return(gap_penalty * len(classes))
	
def getAlignmentScore(classesA,classesB):
    alignA,alignB,score = nw_align(classesA,classesB)
    
    # Work out maximum scores possible
    # This would be the sequence aligned with itself
    x,y,maxAScore = nw_align(classesA,classesA)
    x,y,maxBScore = nw_align(classesB,classesB)
    maxScore = max(maxAScore,maxBScore)
    
    # Work out minimum score possible.
    minScoreA = getMinimumNWScore(classesA)
    minScoreB = getMinimumNWScore(classesB)
    minScore = min(minScoreA,minScoreB)
    
    return((maxScore - score) / float(maxScore - minScore))
    
def matchCogIds(oldWords,newWords,concept):
	# Find keys that match the concept		
	oKeys = getAllKeys(oldWords.get_list(row=concept))
	nKeys = getAllKeys(newWords.get_list(row=concept))
	# Loop through the new words
	for nKey in nKeys:
		nWord = newWords[nKey,"IPA"]
		nClasses = toTokens(nWord)
		# Keep track of results
		results = {}
		oWords = {}
		# For each old word
		for oKey in oKeys:
			oWord = oldWords[oKey,"ipa"]
			oCog = oldWords[oKey,"COGID"]
			oTokens = cleanS(oldWords[oKey,"TOKENS"])
			oClasses = tokens2class(oTokens,"sca")
			# get the alignment score between candidate old word and new word
			score = getAlignmentScore(oClasses,nClasses)
			# Keep track of results
			try:
				results[oCog].append(score)
			except:
				results[oCog] = [score]
			try:
				oWords[oCog].append(oWord)
			except:
				oWords[oCog] = [oWord]

		#print("-------")
		#print(nWord)
	#	print(results)
		# sorted list of averages
		sr = sorted([(sum(results[x])/float(len(results[x])), x ) for x in results.keys()])
		#print(sr)
		#print(sr[0][1],oWords[sr[0][1]])
		# assign best matching cogid 
		newWords[nKey,"COGID"] = sr[0][1]
		
def filterConcepts(wl,conceptSublist):
	outWL = {0: [c for c in newWords.columns]}
	for idx, concept in wl.iter_rows('concept'): 
		if concept in conceptSublist:
			outWL[idx] = [entry for entry in wl[idx]]
	return(outWL)

	
# Main loop
for concept in newWords.concept:
	print(concept)
	if concept in oldWords.concept:
		matchCogIds(oldWords,newWords,concept)

# Now align things

# First, we get cog ids for everything
lex = LexStat(newWords, segments='segments', check=True)
lex.get_scorer(runs=scoringRuns)
lex.cluster(method='lexstat', threshold=0.55, ref="cogid", cluster_method='infomap',force=True)

conceptsMatchedToSagart = [x for x in newWords.concept if x in oldWords.concept]
#conceptsNotInSagart = [x for x in newWords.concept if not x in oldWords.concept]

# Switch cog ids back to Sagart ids where we have them
for idx, concept in lex.iter_rows("concept"):
	if concept in conceptsMatchedToSagart:
		# Warning: hard-coding column 4 (cogid)
		lex[idx][4] = newWords[idx][4]+100000
		
lex.output("tsv",filename = "../data/Sagart_etal_2019/tmp1")

# Create file from old data that we can merge with the new data

# Filter languages to keep
sagartLangsToKeep = ["TibetoKinauri_Byangsi","rGyalrong_Daofu","rGyalrong_Japhug","Karbi","Bodic_Tshangla","Tibeto_Kinauri_Rongpo","Tibetan_Alike","Tibetan_Batang","Tibetan_Lhasa","Tibetan_Xiahe","Khroskyabs_Wobzi","rGyalrong_Maerkang"]
oldWords2 = {0: [c for c in oldWords.columns]}
for idx, doculect in oldWords.iter_rows('doculect'): 
	if doculect in sagartLangsToKeep:
		oldWords2[idx] = [entry for entry in oldWords[idx]]
		print(oldWords2[idx])
		oldWords2[idx][6] = oldWords2[idx][6]+100000
		oldWords2[idx][7] = str(int(oldWords2[idx][7])+100000)
		oldWords2[idx][0] = "S_" + oldWords2[idx][0]

oldLex = LexStat(oldWords2,segments="segments",check=True)
oldLex.get_scorer(runs=scoringRuns)
# Output so we can join the files later
oldLex.output("tsv",filename="../data/Sagart_etal_2019/tmp2")

import pandas as pd

df1 = pd.read_csv("../data/Sagart_etal_2019/tmp1.tsv",sep='\t',quoting=3,encoding="UTF-8",comment='#')
df2 = pd.read_csv("../data/Sagart_etal_2019/tmp2.tsv",sep='\t',quoting=3,encoding="UTF-8",comment='#')

df = pd.concat([df1,df2], ignore_index=True,)
df.to_csv("../data/Sagart_etal_2019/tmp3.tsv", sep='\t', encoding='utf-8',quoting=3)

# Now forced alignment
finalLex = LexStat("../data/Sagart_etal_2019/tmp3.tsv",segments='segments',check=True)
#finalLex.get_scorer(runs=scoringRuns)
alm = Alignments(finalLex, ref='cogid', segments='segments') 
alm.align(method='progressive', scoredict=lex.cscorer)

# Output
alm.output('tsv', filename="../data/processed/240WordList/AllLangs_240_CogID_Sagart")

import os
os.remove("../data/Sagart_etal_2019/tmp1.tsv")
os.remove("../data/Sagart_etal_2019/tmp2.tsv")
os.remove("../data/Sagart_etal_2019/tmp3.tsv")

# Now run R script filterSagartLangs.R to tidy up
os.system("R -f filterSagartLanguages.R")