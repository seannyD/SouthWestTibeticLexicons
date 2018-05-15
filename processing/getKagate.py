#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Only loads data that has no pickle file in `../data/raw/Kagate/pickles/`
#  (delete files to reload)

from bs4 import BeautifulSoup
import urllib
import pickle
import os.path
import time
import codecs
import subprocess

dictLetters = u"आइउएऐओऔकखगघङचछजझटठडढतथदधनपफबभमयरलवसह"


def loadPage(letter,pageNum):
	letterEncode = urllib.parse.quote(letter.encode('utf8'), '/:')
	url = "https://syuba.webonary.org/browse/browse-syuba-nepali/?letter="+letterEncode+"&key=syw&pagenr="+str(pageNum)+"&lang=en"
	filename = "../data/raw/Kagate/tmp/Page_"+str(dictLetters.index(letter))+"_"+str(pageNum)+".txt"
	if not os.path.isfile(filename):
		print( url)
		if not 'driver' in globals():
			from selenium import webdriver
			driver = webdriver.Firefox()
		driver.get(url)
		o = codecs.open(filename,'w',encoding='utf-8')
		o.write(driver.page_source)
		o.close()
		time.sleep(3)
		#h.close()
	s = codecs.open(filename,'r',encoding='utf-8').read()
	return(s)


def hasContent(page):
	return(page.count("No entries exist starting with this letter.")==0)
	
	
def getTagText(entry,tag,properties):
	tags = entry.findAll(tag,properties)
	tags = [x for x in tags if len(x.text.strip())>0]
	if len(tags)>0:
		return( tags[0].text)
	else:
		return ("")

	
def parsePage(page):
	soup = BeautifulSoup(page, "lxml")
	entries = soup.findAll("div", {"class": "entry"})
	processedEntries = []
	for entry in entries:
		ipa = getTagText(entry,"span",{"class": "pronunciations"})
		headword = getTagText(entry,"a",{"class": "headword"})
		pos = getTagText(entry,"span",{"class": "partofspeech"})
		definitions = entry.findAll("span",{"class": "definition"})
		gloss_english =  [getTagText(x,"span",{"lang":"en"}) for x in definitions]
		gloss_nepalese = [getTagText(x,"span",{"lang":"ne"}) for x in definitions]
		semanticDomain = getTagText(entry,"span",{"class":"semantic-domain-abbr_L2"})
		semanticDomain = semanticDomain.replace("-","")
		info = {"ipa":ipa,
				"headword":headword,
				"pos":pos,
				"gloss_english":gloss_english,
				"gloss_nepalese":gloss_nepalese,
				"semanticDomain":semanticDomain}
		processedEntries.append(info)
	return( processedEntries)
		
		
for letter in dictLetters:
	pFileName = "../data/raw/Kagate/pickles/Letter_"+str(dictLetters.index(letter))+".pkl"
	if not os.path.isfile(pFileName):
		entries = []
		keepGoing  = True
		pageNum = 0
		while keepGoing:
			pageNum += 1
			print("Letter "+letter+" page "+str(pageNum))
			page = loadPage(letter,pageNum)			
			#print page
			if hasContent(page):
				page_entries = parsePage(page)
				for entry in page_entries:
					entries.append(entry)
			else:
				keepGoing = False
			
		pickle.dump( entries, open(pFileName , "wb" ) )
		print("\nWritten "+ str(len(entries)) + " entries to "+pFileName+"\n")