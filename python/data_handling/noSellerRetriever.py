from __future__ import division
import os
import sys
import MySQLdb

messedUps = []

# Open Database connection
db = MySQLdb.connect(host='localhost', user='root', passwd='root', db='virtualtrader')
cursor = db.cursor()

# Execute SQL query
cursor.execute('SELECT DISTINCT name FROM transactions ORDER BY name')
db.commit()
results = cursor.fetchall()

# get the list of names of the players
names = []
for r in results:
    names.append(r[0])
players = dict()
listAll = []
for player in names:
    
    query = 'SELECT *  FROM transactions WHERE name="'+str(player)+'"'+ 'ORDER BY date, type'
    cursor.execute(query)
    db.commit()
    results = cursor.fetchall()
    
    listAll.append(player)
    
    for r in results:
        type = str(r[3])
        
        if "Buy" in type:
            players[player] = 1
        
                
finalList = list(set(listAll) - set(players))
print players

query = "DELETE FROM transactions WHERE name = "

for p in finalList:
    query += "'" + p + "' \nOR NAME = "
    
print query
print len(finalList)
