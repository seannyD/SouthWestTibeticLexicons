python2.7 convertGyalsumdoDictionary.py	
python2.7 convertNubriDictionary.py
R -f convertMinorNubriDictionary.R
R -f convertTsumDictionary.R
R -f convertJirelDictionary.R

python2.7 convertLowaDictionary.py
python2.7 convertYolmoDictionary.py

# Kagate scripts run in python 3
python3.6 getKagate.py
python3.6 convertKagateDictionary.py

for lang in Tsum Gyalsumdo Kagate Lowa Nubri Yolmo Jirel; do
concepticon --skip_multimatch map_concepts ../data/processed/${lang}.tsv > ../data/processed/${lang}_advancedMatch.tsv
done