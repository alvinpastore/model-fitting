from __future__ import division
import sys
import MySQLdb
import random
import numpy as np
from datetime import datetime
import time
from math import log
import warnings

''' ---- FUNCTIONS ---- '''



def read_stock_file(path):
    stock_list_file = open(path, 'r')
    stocks = dict()
    risk_flag = 0
    separator = "risk class "
    for line in stock_list_file:
        if separator + str(0) in line:
            risk_flag = 0
        elif separator + str(1) in line:
            risk_flag = 1
        elif separator + str(2) in line:
            risk_flag = 2
        elif separator + str(3) in line:
            risk_flag = 3
        elif separator + str(4) in line:
            risk_flag = 4
        elif line.strip():
            stocks[line.split("~")[0]] = risk_flag

    stock_list_file.close()
    return stocks


def connect_DB(host, user, pw, database):
    # Open Database connection
    db = MySQLdb.connect(host=host, user=user, passwd=pw, db=database)
    cursor = db.cursor()
    return cursor, db


def close_DB():
    db.close()


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


def filter_players(all_players, threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))


def select_transactions(table, name, cursor, db):
    # retrieve all transactions for each player
    query = 'SELECT *  FROM '  + table + ' WHERE name="' + str(name) + '"' + 'ORDER BY date, type'
    try:
        cursor.execute(query)
    except MySQLdb.Error:
        print "Error in QUERY", query
        raw_input("press any key to continue")
    db.commit()
    player_transactions = cursor.fetchall()
    return player_transactions







''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

t0 = time.time()

# Read the stocks previously classified according to their risk (3 bins)
stock_risk = read_stock_file("../../data/risk_classified_stocks_" + str(3) + ".txt")


# connect to DB and get the cursor and the db
c_db = connect_DB('localhost', 'root', 'root', 'virtualtrader')
cursor = c_db[0]
db     = c_db[1]

# retrieve players
db_players = select_players('transactions', cursor, db)
players = sorted(filter_players(db_players, 'players_threshold.txt'))

print
print 'Version history \n' \
      'branch for testing dumb players \n'

print 'total players: ' + str(len(players))

print players


# data structure that contains the MLEs
dumbPlayers = []
dpActions = []
dumbAction = [0, 1, 2]
for player in players:

    print '\n' + str(players.index(player)) + ' : ' + str(player)

    # retrieve the transactions for each player
    transactions = select_transactions('transactions', player, cursor, db)

    actionsAmount = 0
    correct_actions = [0, 0, 0]

    for transaction in transactions:
        if actionsAmount < 25:
            stock = str(transaction[4])
            if 'Sell' in transaction[3] and stock:
                stock = str(transaction[4])

                actionsAmount += 1

                action = stock_risk[stock]

                for dA in dumbAction:
                    if dA == action:
                        correct_actions[dA] += 1
    player_summary = list(np.true_divide(correct_actions, actionsAmount))
    player_summary.append(actionsAmount)
    dumbPlayers.append(player_summary)
    print str(actionsAmount) + ' transactions '

close_DB()

outfile = open('results/dumb_players_25CAP.csv', 'w')

print 'pid \t dp1 \t dp2 \t dp3 \t amount'
for dp in dumbPlayers:
    outfile.write('%d , %0.3f , %0.3f , %0.3f , %d\n' % (dumbPlayers.index(dp), dp[0], dp[1], dp[2], dp[3]))
    print '%d \t %0.3f \t %0.3f \t %0.3f \t %d' % (dumbPlayers.index(dp), dp[0], dp[1], dp[2], dp[3])

outfile.close()
print str((time.time() - t0) / 60) + 'minutes'
