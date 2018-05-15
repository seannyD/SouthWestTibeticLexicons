\+DatabaseType Text
\ver 5.0
\+mkrset 
\lngDefault Default
\mkrRecord ref

\+mkr ELANBegin
\lng Default
\mkrOverThis ref
\mkrFollowingThis ELANEnd
\CharStyle
\-mkr

\+mkr ELANEnd
\lng Default
\mkrOverThis ELANBegin
\mkrFollowingThis ELANParticipant
\CharStyle
\-mkr

\+mkr ELANMediaMIME
\nam *
\lng Default
\mkrOverThis ref
\-mkr

\+mkr ELANMediaURL
\nam *
\lng Default
\mkrOverThis ref
\-mkr

\+mkr ELANParticipant
\lng Default
\mkrOverThis ELANEnd
\mkrFollowingThis ut
\CharStyle
\-mkr

\+mkr ft
\nam free translation
\lng Default
\mkrOverThis ge
\mkrFollowingThis ftn
\CharStyle
\-mkr

\+mkr ftn
\nam nepali free translation
\lng Nepali Unicode
\mkrOverThis ft
\CharStyle
\-mkr

\+mkr ge
\nam gloss in english
\lng Default
\mkrOverThis mb
\mkrFollowingThis ft
\CharStyle
\-mkr

\+mkr mb
\nam morpheme breaks
\lng IPA Unicode
\+fnt 
\Name Doulos SIL
\Size 12
\charset 00
\rgbColor 0,0,255
\-fnt
\mkrOverThis tx
\mkrFollowingThis ge
\CharStyle
\-mkr

\+mkr ref
\lng Default
\mkrFollowingThis ELANBegin
\-mkr

\+mkr tx
\nam text
\lng IPA Unicode
\+fnt 
\Name Doulos SIL
\Size 12
\charset 00
\rgbColor 255,0,0
\-fnt
\mkrOverThis ut
\mkrFollowingThis mb
\CharStyle
\-mkr

\+mkr ut
\nam utterance
\lng IPA Unicode
\+fnt 
\Name Doulos SIL
\Size 12
\charset 00
\rgbColor 0,0,0
\-fnt
\mkrOverThis ELANParticipant
\mkrFollowingThis tx
\CharStyle
\-mkr

\-mkrset

\iInterlinCharWd 8

\+intprclst 
\fglst {
\fglend }
\mbnd +
\mbrks -

\+intprc Lookup
\bParseProc
\mkrFrom tx
\mkrTo mb

\+triLook 
\+drflst 
\-drflst
\-triLook

\+triPref 
\dbtyp Lexicon
\+drflst 
\+drf 
\File F:\a_Nubri_all_Janchuk\Glossary_Nubri_Dec28_2017\Glossary_Dec_2017_finalediting\Lexicon.txt
\-drf
\-drflst
\+mrflst 
\mkr lx
\mkr a
\-mrflst
\mkrOut u
\-triPref

\+triRoot 
\dbtyp Lexicon
\+drflst 
\+drf 
\File F:\a_Nubri_all_Janchuk\Glossary_Nubri_Dec28_2017\Glossary_Dec_2017_finalediting\Lexicon.txt
\-drf
\-drflst
\+mrflst 
\mkr lx
\mkr a
\-mrflst
\mkrOut u
\-triRoot
\GlossSeparator ;
\FailMark *
\bShowFailMark
\bShowRootGuess
\-intprc

\+intprc Lookup
\mkrFrom mb
\mkrTo ge

\+triLook 
\dbtyp Lexicon
\+drflst 
\+drf 
\File F:\a_Nubri_all_Janchuk\Glossary_Nubri_Dec28_2017\Glossary_Dec_2017_finalediting\Lexicon.txt
\-drf
\-drflst
\+mrflst 
\mkr lx
\mkr a
\mkr u
\-mrflst
\mkrOut ge
\-triLook
\GlossSeparator ;
\FailMark ***
\bShowFailMark
\bShowRootGuess
\-intprc

\-intprclst
\+filset 

\-filset

\+jmpset 
\+jmp jump
\+mkrsubsetIncluded 
\mkr mb
\-mkrsubsetIncluded
\+drflst 
\+drf 
\File F:\a_Nubri_all_Janchuk\Glossary_Nubri_Dec28_2017\Glossary_Dec_2017_finalediting\Lexicon.txt
\mkr lx
\-drf
\-drflst
\-jmp
\-jmpset

\+template 
\-template
\mkrRecord ref
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
\InterlinearSpacing 120
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
\-expSF

\SkipProperties
\-expset
\-DatabaseType
