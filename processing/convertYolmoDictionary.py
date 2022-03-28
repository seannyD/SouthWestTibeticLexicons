import codecs, re, ast

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


def loadTranslationFile(file):
	o = codecs.open(file,'r',encoding='utf8')
	cs = o.read()
	o.close()

	dict = {}

	i = 0

	lines = cs.split("\n")

	while i < len(lines):
		source = lines[i]
		to = lines[i+1]
		#print source
		#print to
		#print "--"
		for j in range(len(source)):
			if to[j]!="_":
				dict[source[j]] = to[j]
		i += 2
	
	
	return(dict)
	
def translate(text,dict):
	return "".join([dict[x] for x in text])

glossTranslation = loadTranslationFile("../data/raw/Yolmo/characterTranslations_Gloss.txt")
ipaTranslation = loadTranslationFile("../data/raw/Yolmo/characterTranslations_IPA.txt")

print ipaTranslation


o = codecs.open("../data/raw/Yolmo/Yolmo_text.txt",'r',encoding='utf8')
yolmo = o.read()
o.close()

yolmo = yolmo.replace("##","#")
yolmo = yolmo.replace('+ ',"+\n")
yolmo = re.sub("#\n([^!])",r"#\1",yolmo)
yolmo = re.sub("([^<]) !",r"\1\n!",yolmo)

print yolmo

out = "ID	DOCULECT	CONCEPT	CONCEPTID	TRANSCRIPTION	SEGMENTS	COGID	GLOSS\n"

missing = []

idNum = 0

for line in yolmo.split("\n"):
	print "-------------"
	if line.startswith("#"):
		line = line[1:]
	if line.startswith("!"):
		line = line[1:]
	
	if line.count("#!")>0 and line.count("&")>0 and line.count("#")>0 and line.count("+")>0 and line.count("O/8H-5,")==0:
		print line
#		try:
		bracketOpen = line.index("#!")+1
		if line.count(' !')>0:
			bracketOpen = min(bracketOpen,line.index(" !")+1)
		if line.count('!!')>0:
			bracketOpen = min(bracketOpen,line.index("!!")+1)
		if line[bracketOpen:].count("&")>0:
			bracketClosed = line.index("&",bracketOpen)
			if line[bracketClosed+2:].count('#')>0:
				glossStart = line.index("#",bracketClosed+2)+1
				glossEnd = line.index("+",glossStart)
				if line[bracketClosed:glossEnd].count('"#')>0:
					glossStart = max(glossStart,line[:glossEnd].rindex('"#',bracketClosed)+2)
		#		except:
		#			pass
				ipa = line[bracketOpen+1:bracketClosed]
				gloss = line[glossStart:glossEnd]
				gloss = gloss.replace("  ","")
	
				print "IPA>"+ipa+"<"
				print "GLOSS>"+gloss+"<"
				try:
					ipa_trans = translate(ipa,ipaTranslation)
					gloss_trans = translate(gloss,glossTranslation)

					print ipa_trans
					print gloss_trans
			
					concept = findConcept(gloss_trans)
					idNum += 1
					print idNum
		
					out += "\t".join([str(idNum), "Yolmo",concept[1],concept[0],ipa_trans,"","",gloss_trans]) + "\n"
			

				except:
					pass	


o = codecs.open("../data/processed/Yolmo.tsv",'w',encoding='utf8')
o.write(out)
o.close()
print "\n\n Written to ../data/processed/Yolmo.tsv\n\n"

