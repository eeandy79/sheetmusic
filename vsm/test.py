import sys, urllib, urllib2, cookielib
from bs4 import BeautifulSoup 
import re
import sqlite3

con = sqlite3.connect('test.sqlite')
cur = con.cursor()
cur.execute('DROP TABLE IF EXISTS music')
cur.execute('CREATE TABLE music(composer TEXT, pdf_url TEXT)')
con.commit()

hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
       'Accept-Encoding': 'none',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection': 'keep-alive'}


url_list = [ "http://violinsheetmusic.org/classical/a/",
             "http://violinsheetmusic.org/classical/b/",
             "http://violinsheetmusic.org/classical/c/",
             "http://violinsheetmusic.org/classical/d/",
             "http://violinsheetmusic.org/classical/e/",
             "http://violinsheetmusic.org/classical/f/",
             "http://violinsheetmusic.org/classical/g/",
             "http://violinsheetmusic.org/classical/h/",
             "http://violinsheetmusic.org/classical/i/",
             "http://violinsheetmusic.org/classical/j/",
             "http://violinsheetmusic.org/classical/k/",
             "http://violinsheetmusic.org/classical/l/",
             "http://violinsheetmusic.org/classical/m/",
             "http://violinsheetmusic.org/classical/n/",
             "http://violinsheetmusic.org/classical/o/",
             "http://violinsheetmusic.org/classical/p/",
             "http://violinsheetmusic.org/classical/q/",
             "http://violinsheetmusic.org/classical/r/",
             "http://violinsheetmusic.org/classical/s/",
             "http://violinsheetmusic.org/classical/t/",
             "http://violinsheetmusic.org/classical/u/",
             "http://violinsheetmusic.org/classical/v/",
             "http://violinsheetmusic.org/classical/w/",
             "http://violinsheetmusic.org/classical/x/",
             "http://violinsheetmusic.org/classical/y/",
             "http://violinsheetmusic.org/classical/z/",
           ]

for url in url_list:
	print url
	req = urllib2.Request(url, headers=hdr)

	try:
		page = urllib2.urlopen(req)
	except urllib2.HTTPError, e:
		#print e.fp.read()
		continue

	# foundtext contains all composer for one alphebet
	foundtext = BeautifulSoup(page.read(), 'html5lib').find('h1')

	for link in foundtext.findAllNext('a'):
		if "classical" in link.get('href'):
			composer_name = link.contents[0]

			# open page contains all songs from one composer
			req = urllib2.Request(link.get('href'), headers=hdr)
			page = urllib2.urlopen(req)
			foundtext2 = BeautifulSoup(page.read(), 'html5lib').find('h1')

			for link2 in foundtext2.findAllNext('a'):
				if "violin.pdf" in link2.get('href'):
					pdf_url_value = link2.get('href')

					values = {'composer':composer_name, 'pdf_url':pdf_url_value}
					#print url
					con.execute("insert into music VALUES (:composer, :pdf_url)", values);

con.commit()

#print cur.lastrowid
#cur.execute('SELECT * FROM music')
#print cur.fetchall()

#print soup.findAll('a', href=True)
#print content



