import sys, urllib, urllib2, cookielib
from bs4 import BeautifulSoup 
import re
import sqlite3

con = sqlite3.connect('test.sqlite')
cur = con.cursor()
cur.execute('DROP TABLE IF EXISTS archive')
cur.execute('CREATE TABLE archive(guid TEXT, filePath TEXT)')
cur.commit()

