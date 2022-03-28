from lingpy import *
#from lingpy.tests.util import test_data

wl = Wordlist('../data/Sagart_etal_2019/Dhakal_and_Sagart_data.tsv')

for key in wl:
	if "".join(wl[key,"TOKENS"]) == "":
		wl[key,"TOKENS"] = ipa2tokens(wl[key,"IPA"])
		print( ipa2tokens(wl[key,"IPA"]))

print("LOADED WORDLIST\n\n")


lex = LexStat(wl, check=True)

lex.get_scorer(runs=10000)
lex.cluster(method='sca', threshold=0.55, ref="cogid", cluster_method='infomap')
lex.output('tsv', filename='../data/Sagart_etal_2019/Dhakal_and_Sagart_data_clustered')

#alm = Alignments(lex, ref='cogid', segments='tokens') 
#alm.align(method='progressive', scoredict=lex.cscorer)
#alm.output('tsv', filename='../../results/cognateDetection/AllLangs_240_lexstat_aligned')