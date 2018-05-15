import re, codecs, ast

o = codecs.open("../data/reference/concepticon_conceptset.json/conceptset.json",'r',encoding='utf8')
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
		



o = codecs.open("../data/raw/Gyalsumdo/Gyal_Dic.txt",'r',encoding='utf8')
d = o.read()
o.close()


d = d.replace("\n\t"," ")
d = d.replace("  "," ")

out = "ID	DOCULECT	CONCEPT	CONCEPTID	TRANSCRIPTION	SEGMENTS	COGID	GLOSS	script1	script2	pos\n"

idNum = 0

for line in d.split("\n"):
	line = line.replace("\t"," ")
	line = line.replace("  "," ")
	if len(line.strip())>7:
		print line
		idNum += 1
		line = line.strip()
		
		ipa = line[:line.index("[")].strip()
		script1 = line[line.index("[")+1:line.index("]")].strip()
		
		if line[line.index("]")+1:].count(".")==2:
			pos = line[line.index("]")+1:line.index(".",line.index("]"))].strip()
			# multiple categories
		else:
			pos = line[line.index("]")+1:line.index(".",line.index(".")+1)].strip()
		
		gloss = line.split(".") 
		#line[line.rindex(".",line.rindex(".")-1):line.rindex(".")].strip()
		gloss = gloss[-2].strip()
		
		concept = findConcept(gloss)
		concept[0] = str(concept[0])
				
		script2 = line[line.rindex(".")+1:].strip()
		
		out += "\t".join([str(idNum), "Gyalsumdo",concept[1],concept[0],ipa,"","",gloss,script1,script2,pos]) + "\n"




		
		
o = codecs.open("../data/processed/Gyalsumdo.tsv",'w',encoding='utf8')
o.write(out)
o.close()
print "\n\n Written to ../data/processed/Gyalsumdo.tsv\n\n"