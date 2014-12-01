from __future__ import division
import operator
import MySQLdb
import random
import numpy as np
from datetime import datetime
import time
from math import log
import warnings


def connect_DB(host, user, pw, database):
    # Open Database connection
    dBase = MySQLdb.connect(host=host, user=user, passwd=pw, db=database)
    curs = dBase.cursor()
    return curs, dBase


def select_players(table, cursor, db):

    # Execute SQL query
    cursor.execute('SELECT DISTINCT name FROM ' + table + ' ORDER BY name')
    db.commit()
    results = cursor.fetchall()
    # get the list of names of the players
    names = []
    for r in results:
        names.append(r[0])
    return names

def filter_players(all_players,threshold_file):
    t_players =  [line.rstrip('\n') for line in open(threshold_file,'r')]
    return list(set(all_players).intersection(set(t_players)))

def close_DB():
    db.close()


def select_transactions(table, pname):
    # retrieve all transactions for each player
    query = 'SELECT *  FROM '  + table + ' WHERE name="' + str(pname) + '"' + 'ORDER BY date, type'
    try:
        cursor.execute(query)
    except MySQLdb.Error, e:
        print "Error in QUERY", query
        raw_input("press any key to continue")
    db.commit()
    player_transactions = cursor.fetchall()
    return player_transactions

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

t0 = time.time()

# connect to DB and get the cursor and the db
c_db = connect_DB('localhost', 'root', 'root', 'virtualtrader')
cursor = c_db[0]
db     = c_db[1]


# retrieve players
db_players = select_players('transactions', cursor, db)
players = sorted(filter_players(db_players,'players_threshold.txt'))
performances = dict()
print
print 'Version history \n' \
    '0.0.1 first draft for calculating performance \n'

for player in players:
    print '\n' + str(players.index(player)) +' : '+ str(player)

    money = 100000
    # retrieve the transactions for each player
    transactions = select_transactions('transactions', player)

    # store the stocks purchased for future estimation of reward
    portfolio = dict()

    for transaction in transactions:


        if 'Buy' in transaction[3] or 'Sell' in transaction[3]:


            name = str(transaction[1])
            date_string = str(transaction[2]).split(' ')[0].replace('-',' ')
            date        = datetime.strptime(date_string,'%Y %m %d')
            a_type      = str(transaction[3])
            stock       = str(transaction[4])
            volume      = int(transaction[5])
            price       = float(transaction[6])
            total       = float(transaction[7])
            if 'Buy' in a_type and stock:

                # save the stocks that have been purchased
                if stock in portfolio:
                    old_volume = portfolio[stock][0]
                    old_price  = portfolio[stock][1]
                    old_total  = portfolio[stock][2]
                    new_volume = volume + old_volume
                    new_price  = (total + old_total) / (volume + old_volume)
                    new_total  = old_total + total

                    #if 'niktai' in player and 'Rolls' in stock:
                    #    print 'old_price',old_price
                    #    print 'old_volume',old_volume
                    #    print 'old_total',old_total
                    #    print 'price',price
                    #    print 'volume',volume
                    #    print 'total',total
                    #    print 'new_total',new_total
                    portfolio[stock] = (new_volume, new_price, new_total)
                else:
                    portfolio[stock] = (volume, price, total)

                # deduct money spent to purchase stock
                # (+ sign because the sign of the total is negative for purchases)
                money += total
            elif 'Sell' in a_type and stock:

                if stock not in portfolio:
                    print ':::::::::::::::::::::::::::::::::::::::::::::::'
                    print player
                    print 'stock', stock
                    print 'portfolio', portfolio
                    # messed up player
                    break
                else:

                    old_volume = portfolio[stock][0]
                    old_price  = portfolio[stock][1]
                    old_total  = portfolio[stock][2]

                    # if all shares for the stock have been sold delete stock from portfolio
                    # otherwise update the values (new_volume, old_price, new_total)
                    new_volume = old_volume - volume
                    if new_volume <= 0:
                        del portfolio[stock]
                    else:

                        new_total = new_volume * old_price
                        # the asset (selling power) is still
                        # the old price (which is the avg of all the buying prices normalised on the volumes)
                        # times the new amount of stocks held

                        portfolio[stock] = (new_volume, old_price, new_total)
                        # old_price so it is possible to calculate margin for future sells




                    # update money with gain/loss from sell
                    money += total


    assets = 0
    for s in portfolio:
        assets += portfolio[s][2]

    # assets values are negative for holdings
    performances[player] = money - assets


print
for pl in sorted(performances.items(), key=operator.itemgetter(1)):
    print str(pl[0]) + ': ' + str(pl[1])

print


close_DB()
final_time = (time.time() - t0)
print("%.2f secs" % final_time)