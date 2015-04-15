__author__ = 'alvin'
import MySQLdb


class DatabaseHandler:

    def __init__(self, host, user, pw, database):
        # Open Database connection
        self.d = MySQLdb.connect(host=host, user=user, passwd=pw, db=database)
        print self.d
        self.c = self.d.cursor()
        print self.c

    def close(self):
        self.d.close()
        print '\nDB closed'

    def select_players(self, table):
        # Execute SQL query
        self.c.execute('SELECT DISTINCT name FROM ' + table + ' ORDER BY name')
        self.d.commit()
        # return the list of names of the players
        return [r[0] for r in self.c.fetchall()]

    def select_transactions(self, table, name):
        # retrieve all transactions for each player
        query = 'SELECT *  FROM '  + table + ' WHERE name="' + str(name) + '"' + 'ORDER BY date, type'
        try:
            self.c.execute(query)
        except MySQLdb.Error:
            raw_input("Error in QUERY " + query + "\nPress any key to continue")
        self.d.commit()
        # return player_transactions
        return self.c.fetchall()

'''
# MAIN
db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

db_players = db.select_players('transactions')
print db_players

transactions = db.select_transactions('transactions', db_players[0])
print transactions

db.close()
'''