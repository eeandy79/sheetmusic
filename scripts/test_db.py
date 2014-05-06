import sqlite3

con = sqlite3.connect('mydatabase.sqlite')

cur = con.cursor()

#cur.execute('CREATE TABLE foo (o_id INTEGER PRIMARY KEY, fruit VARCHAR(20), veges VARCHAR(30))')
#con.commit()
#cur.execute('INSERT INTO foo (o_id, fruit, veges) VALUES (NULL, "apple", "broccoli")')
#con.commit()
#print cur.lastrowid

#cur.execute('SELECT composer FROM music')
#print cur.fetchall()

cur.execute("SELECT pdf_url FROM music where composer=:composer", {"composer": 'Ascher, Joseph'})
print cur.fetchall()


