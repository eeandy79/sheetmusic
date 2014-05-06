import sqlite3
import uuid

con = sqlite3.connect('mydatabase.sqlite')

cur = con.cursor()

cur.execute('DROP TABLE IF EXISTS music2')
cur.execute('CREATE TABLE music2(composer TEXT, song_title TEXT, pdf_url TEXT, guid TEXT)')

cur.execute('DROP TABLE IF EXISTS archive')
cur.execute('CREATE TABLE archive(guid TEXT, filePath TEXT)')

cur.execute('SELECT * FROM music')
res = cur.fetchall()

for line in res:
	guid = uuid.uuid4()
	values = {'composer':line[0], 'song_title':line[1], 'pdf_url':line[2], 'guid':str(guid)}
	con.execute("insert into music2 VALUES (:composer, :song_title, :pdf_url, :guid)", values);

con.commit()


cur.execute('SELECT * FROM music2')
res = cur.fetchall()

print res


# create new table
#cur.execute('DROP TABLE IF EXISTS music')
