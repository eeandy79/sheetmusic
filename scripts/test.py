import sys, urllib, urllib2, cookielib
from bs4 import BeautifulSoup 
import re
import sqlite3

with open ("bach.html", "r") as myfile:
	data = myfile.read()

foundtext = BeautifulSoup(data, 'html5lib').find('h1')

for urls in foundtext.findAllNext('a'):
	if ".pdf" in urls.get('href'):
		if "violin" in urls.contents[0]:
			url_value = urls.get('href')
			split_result = url_value.split('/')
			print split_result[len(split_result)-1]
			print urls.get('href')
		elif "score, piano" not in urls.contents[0]:
			print urls.contents[0] + urls.get('href')
			

#for link2 in foundtext2.findAllNext('a'):
#	if "violin.pdf" in link2.get('href'):
#		pdf_url_value = link2.get('href')


