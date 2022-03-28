#####################
# Convert big lists #
#####################

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

##########################
# Convert 240 word lists #
##########################

R -f convert240WordLists.R

##################
# Cognate coding #
##################

# Clean Sagart data and match to concepticon concepts
R -f addConcepticonToSagart.R
# Creates data/Sagart_etal_2019/sino-tibetan-cleaned-concepticon3.tsv

# Match our data to cognate IDs from Sagart paper
# Sagart cognate IDs will be at least 100000
# And run standard cognate coding on the rest.
# Add some extra Sagart languages
# Align all the data
python3 compareToSagart.py
# Creates data/processed/240WordList/AllLangs_240_CogID_Sagart.tsv
# This script also runs an R script to filter concepts and 
#  cognate IDs that don't appear in our data.
#  (R -f filterSagartLanguages.R)


# AllLangs_240_CogID_Sagart.tsv is then manually edited by hand in Edictor
# to produce data/corrected/AllLangs_240_CogID_Sagart_Complete.tsv

# At this point, we found the extended version of the Sagart data, 
#  which boosts the number of overlapping concepts from 87 to 145
# This script combines the manually edited file with the extended server data:
#  to produce data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended.tsv
R -f combineCorrectedAndServerFile.R

# Now we re-edited this file by hand to align all the data
# Ends up with data/corrected/AllLangs_240_CogID_Sagart_Complete_Extended_Checked4.tsv

# Select data to run phylogenetic tree on:
R -f makeBeastXMLFiles.R
# Creates single partition file "../data/BEAST/Tibetan_SinglePartition.nex"
# Creates an xml file for each partition in data/BEAST/partitions/

# Use Beauti to create Beast xml files

# Run Beast
cd data/BEAST/
/Applications/BEAST\ 2.6.2/bin/beast Tibetan_SinglePartition_Covarion_noTibetanPrior.xml
# Move results files to the results folder
mv Tibetan_SinglePartition_Covarion_noTibetanPrior.trees ../../results/BEAST/covarion_noTibetanPrior2/Tibetan_SinglePartition_Covarion_noTibetanPrior.trees
mv Tibetan_SinglePartition_Covarion_noTibetanPrior.log ../../results/BEAST/covarion_noTibetanPrior2/Tibetan_SinglePartition_Covarion_noTibetanPrior.log
mv Tibetan_SinglePartition_Covarion_noTibetanPrior.xml.state ../../results/BEAST/covarion_noTibetanPrior2/Tibetan_SinglePartition_Covarion_noTibetanPrior.xml.state
cd ../../

# Use tracer to check trace, pick burnin

# Use log combiner to resample and apply burnin.
# There are 3,300,000 states. So take 10% burnin and resample at 3000 to get 10k trees

cd results/BEAST/covarion_noTibetanPrior2/

/Applications/BEAST\ 2.6.2/bin/logcombiner -log Tibetan_SinglePartition_Covarion_noTibetanPrior.trees -o Tibetan_SinglePartition_Covarion_noTibetanPrior_10k.trees -b 10 -resample 3000

# MCCT using median heights
/Applications/BEAST\ 2.6.2/bin/treeannotator -heights median -b 0 -limit 0 Tibetan_SinglePartition_Covarion_noTibetanPrior_10k.trees Tibetan_SinglePartition_Covarion_noTibetanPrior_10k_MCCT.trees

# Densitree
/Applications/BEAST\ 2.6.2/bin/densitree Tibetan_SinglePartition_Covarion_noTibetanPrior_10k.trees
cd ../../../