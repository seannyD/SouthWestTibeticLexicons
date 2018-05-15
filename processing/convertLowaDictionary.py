#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re, codecs, ast, string

o = codecs.open("../data/reference/concepticon_conceptset.json/conceptset.json",'r',encoding='utf8')
cs = o.read()
o.close()

concepts = ast.literal_eval(cs)


def findConcept(gloss):
	gloss2 = gloss.strip().lower()
	gloss2 = gloss2.replace("  ","")
	if gloss2 in concepts['conceptset_labels'].keys():
		return concepts['conceptset_labels'][gloss2]
	if gloss2 in concepts['alternative_labels'].keys():
		return concepts['alternative_labels'][gloss2]
	if gloss2.count(",")>0:
		#gloss2 = gloss2[:gloss2.index(",")].strip()
		for part in gloss2.split(","):
			cp = findConcept(part)
			if cp[0]!="":
				return cp
# 		if gloss2 in concepts['conceptset_labels'].keys():
# 			return concepts['conceptset_labels'][gloss2]
# 		if gloss2 in concepts['alternative_labels'].keys():
# 			return concepts['alternative_labels'][gloss2]
	return ["",""]
	
def fixIPA(ipa):
	ipa = ipa.replace("j","ʲ")
	# TODO: normal h has vowel after, aspiration has consonant before
	#ipa = ipa.replace("h","ʰ")
	return ipa
		



o = codecs.open("../data/raw/Lowa/Lowa.txt",'r',encoding='utf8')
d = o.read()
o.close()

out = "ID	DOCULECT	CONCEPT	CONCEPTID	TRANSCRIPTION	SEGMENTS	COGID	GLOSS	script\n"
idNum  = 0
for line in d.split("\n"):
	line = line.strip()
	if line.count("[") ==1 and line.count("]") ==1 and line[-1] in string.ascii_lowercase[:26] and line.count(")")==0:
		#print line
		idNum += 1
		#शामा्पोक्कीि [ʟsama Hpok‍kin] न्.प. खयािया्तल्रायाख्िल remove food from the heat
		ipa = fixIPA(line[line.index("[")+1:line.index("]")])
		glossRE = re.search("[a-z, ]+$",line)
		if glossRE!=None:
			gloss = glossRE.group(0)
			scriptTrans = line[:line.index("[")].strip()

		
			concept = findConcept(gloss)
		
			out += "\t".join([str(idNum), "Lowa",concept[1],concept[0],ipa,"","",gloss,scriptTrans]) + "\n"

o = codecs.open("../data/processed/Lowa.tsv",'w',encoding='utf8')
o.write(out)
o.close()
print "\n\n Written to ../data/processed/Lowa.tsv\n\n"