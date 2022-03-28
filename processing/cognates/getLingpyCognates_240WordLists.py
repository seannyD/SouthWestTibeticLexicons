from lingpy import *
#from lingpy.tests.util import test_data

wl = LexStat('../../data/processed/240WordList/AllLangs_240.qlc', check=True)

print("LOADED WORDLIST\n\n")


lex = LexStat(wl, segments='segments', check=True)
#lex.cluster(method='turchin', ref='turchinid')
#lex.output('tsv', filename='../../results/cognateDetection/AllLangs_240_turchin', ignore=[])

lex.get_scorer(runs=10000)
lex.cluster(method='lexstat', threshold=0.55, ref="cogid", cluster_method='infomap')
lex.output('tsv', filename='../../results/cognateDetection/AllLangs_240_lexstat')

alm = Alignments(lex, ref='cogid', segments='tokens') 
alm.align(method='progressive', scoredict=lex.cscorer)

alm.output('tsv', filename='../../results/cognateDetection/AllLangs_240_lexstat_aligned')