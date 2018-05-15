\+DatabaseType Lexicon
\ver 5.0
\+mkrset 
\lngDefault Default
\mkrRecord lx

\+mkr a
\lng IPA Unicode
\mkrOverThis lx
\CharStyle
\-mkr

\+mkr ex
\nam example
\lng Default
\mkrOverThis gn
\CharStyle
\-mkr

\+mkr ge
\nam gloss in english
\lng Default
\mkrOverThis ps
\mkrFollowingThis lxd
\CharStyle
\-mkr

\+mkr gn
\nam gloss in nepali
\lng Nepali Unicode
\mkrOverThis pr
\mkrFollowingThis ex
\CharStyle
\-mkr

\+mkr lx
\nam lexeme
\lng IPA Unicode
\+fnt 
\Name Doulos SIL
\Size 12
\charset 00
\rgbColor 255,0,0
\-fnt
\mkrFollowingThis ps
\-mkr

\+mkr lxd
\nam lexeme in devanagari
\lng Nepali Unicode
\mkrOverThis ge
\mkrFollowingThis pr
\CharStyle
\-mkr

\+mkr pr
\nam pronounciation
\lng IPA Unicode
\mkrOverThis lxd
\mkrFollowingThis gn
\CharStyle
\-mkr

\+mkr ps
\nam part of speech
\lng Default
\mkrOverThis lx
\mkrFollowingThis ge
\CharStyle
\-mkr

\+mkr u
\lng IPA Unicode
\mkrOverThis lx
\mkrFollowingThis ge
\CharStyle
\-mkr

\-mkrset

\iInterlinCharWd 8
\+filset 

\+fil Adjective
\mkr ps
\txt adj.
\match_char c
\-fil

\+fil Affixes
\mkr ps
\txt -
\match_char c
\-fil

\+fil Noun
\mkr ps
\txt n.
\match_char c
\-fil

\+fil Verb
\mkr ps
\txt v.
\match_char c
\-fil

\-filset

\+jmpset 
\-jmpset

\+template 
\-template
\mkrRecord lx
\+PrintProperties 
\header File: &fDate: &d
\footer Page &p
\topmargin 1.00 in
\leftmargin 0.25 in
\bottommargin 1.00 in
\rightmargin 0.25 in
\recordsspace 10
\-PrintProperties
\+expset 

\+expRTF Rich Text Format
\exportedFile F:\a_Nubri_all_Janchuk\Glossary_Nubri_Dec28_2017\Nubri_Dec.rtf
\MarkerFont
\+rtfPageSetup 
\paperSize letter
\topMargin 1
\bottomMargin 1
\leftMargin 1.25
\rightMargin 1.25
\gutter 0
\headerToEdge 0.5
\footerToEdge 0.5
\columns 1
\columnSpacing 0.5
\-rtfPageSetup
\-expRTF

\+expSF Standard Format
\exportedFile F:\a_Nubri_all_Janchuk\Glossary_Nubri_Dec28_2017\Nubri
\-expSF

\expDefault Rich Text Format
\SkipProperties
\-expset
\-DatabaseType
