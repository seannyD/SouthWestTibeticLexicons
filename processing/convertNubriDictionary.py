# ../data/raw/Nubri/Lexicon.txt is a Toolbox file format

import re, codecs, ast

o = codecs.open("../data/reference/concepticon_conceptset.json/conceptset.json"'r',encoding='utf8')
cs = o.read()
o.close()

concepts = ast.literal_eval(cs)


def findConcept(gloss):
	gloss2 = gloss.strip().lower()
	if gloss2 in concepts['conceptset_labels'].keys():
		return concepts['conceptset_labels'][gloss2]
	if gloss2 in concepts['alternative_labels'].keys():
		return concepts['alternative_labels'][gloss2]
	return ["",""]
	

o = codecs.open("../data/raw/Nubri/Lexicon.txt",'r',encoding='utf8')
d = o.read()
o.close()

d = d.replace("\r\n","\n")


out = "ID	DOCULECT	CONCEPT	CONCEPTID	TRANSCRIPTION	SEGMENTS	COGID	GLOSS	pos\n"

idNum = 0
for entry in d.split("\n\n")[1:]:
	if len(entry)>4:
		idNum += 1
		entry = u"\n"+entry
		bits = [(x[:x.index(" ")],x[x.index(" ")+1:]) for x in entry.split("\n\\")[1:]]
	

		trans = [x[1] for x in bits if x[0]=="lx"][0].replace("\n","")
		pos = [x[1] for x in bits if x[0]=="ps"][0].replace("\n","")
		gloss = [x[1] for x in bits if x[0]=="ge"][0].replace("\n","")

		concept = findConcept(gloss)

		out += "\t".join([str(idNum),"Nubi",str(concept[1]),str(concept[0]),trans,"","",gloss,pos])+"\n"
	
	
	
		
o = codecs.open("../data/processed/Nubri.tsv",'w',encoding='utf8')
o.write(out)
o.close()
print "\n\n Written to ../data/processed/Nubri.tsv\n\n"