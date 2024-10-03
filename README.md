# Southwest Tibetic Lexicons

Data and code for running Bayesian phylogenetic analyses of Southwest Tibetic languages, as documented in:

Dhakal, D. N., List, J-. M-. and Roberts, S. G. (2024) A phylogenetic study of South-Western Tibetic. *Journal of Language Evolution**. [10.1093/jole/lzae008](10.1093/jole/lzae008)

A lot of the code is for extrating the lexical data from the original dictionary formats and converting to CLDF. However, if you are interested in obtaining the lexical or cognate data, it is better to use the CLDF repository:

[https://github.com/lexibank/dhakalsouthwesttibetic](https://github.com/lexibank/dhakalsouthwesttibetic)

For the Bayesian analyses, the most up-to-date data comes from  [data/JML_Cognate_Coding/JML_withSagart_combined2.tsv](data/JML_Cognate_Coding/JML_withSagart_combined2.tsv).

The files for BEAST are produced using `processing/makeBeastXMLFiles_JML2.R`, which creates files in data/BEAST/ (e.g. the final tree comes from `data/BEAST/JMLwithSagart_combined2_relaxed_3Site_fossilised.xml`). The final phylogeny results for the published paper are in `results/BEAST/jml_combined2_relaxed_3site_fossilised/`.