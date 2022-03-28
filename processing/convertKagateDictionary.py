import pickle
import os
import codecs,ast

o = codecs.open("../data/reference/concepticon_conceptset.json/conceptset.json",'r',encoding='utf8')
cs = o.read()
o.close()

concepts = ast.literal_eval(cs)


def findConcept(gloss):
	gloss2 = gloss.strip().lower()
	gloss2 = gloss2.replace("  ","")
	if gloss2 in concepts['conceptset_labels'].keys():
		return(concepts['conceptset_labels'][gloss2])
	if gloss2 in concepts['alternative_labels'].keys():
		return(concepts['alternative_labels'][gloss2])
	if gloss2.count(",")>0:
		#gloss2 = gloss2[:gloss2.index(",")].strip()
		for part in gloss2.split(","):
			cp = findConcept(part)
			if cp[0]!="":
				return(cp)
# 		if gloss2 in concepts['conceptset_labels'].keys():
# 			return concepts['conceptset_labels'][gloss2]
# 		if gloss2 in concepts['alternative_labels'].keys():
# 			return concepts['alternative_labels'][gloss2]
	return(["",""])


out = "ID	DOCULECT	CONCEPT	CONCEPTID	TRANSCRIPTION	SEGMENTS	COGID	GLOSS	nepaleseGloss	pos	headword	semanticDomain\n"

idNum = 0

base = "../data/raw/Kagate/pickles/"

for file in os.listdir(base):
	if file.endswith(".pkl"):
		entries = pickle.load( open( base +file,'rb'))
		for entry in entries:
			idNum += 1
			print(entry)
			
			concept = ["",""]
			if len(entry["gloss_english"])>0:
				concept = findConcept(entry["gloss_english"][0])
			
			gloss = ";".join(entry["gloss_english"])
			gloss_ne = ";".join(entry["gloss_nepalese"])
			ipa =entry["ipa"].replace("\n","").replace("[","").replace("]","")
			
			out += "\t".join(	[ x.strip() for x in [
				str(idNum),
				"Kagate",
				concept[1],
				concept[0],
				ipa,
				"",
				"",
				gloss,
				gloss_ne,
				entry["pos"],
				entry["headword"],
				entry["semanticDomain"]
			]]).replace("\n","")+"\n"
			
o = codecs.open("../data/processed/Kagate.tsv",'w',encoding='utf8')
o.write(out)
o.close()
print("\n\n Written to ../data/processed/Kagate.tsv\n\n")