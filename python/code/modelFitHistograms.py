from __future__ import division
import os
import sys
import MySQLdb
import random
import numpy as np
from datetime import datetime
from math import log
import operator

''' ---- FUNCTIONS ---- '''
def read_stock_file(path):
    stock_list_file = open(path, 'r')
    stocks = dict()
    risk_flag = 0

    for line in stock_list_file:
        if "LOW" in line:
            risk_flag = 0
        elif "MID" in line:
            risk_flag = 1
        elif "HIGH" in line:
            risk_flag = 2
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


def select_transactions(table, name, cursor, db):
    # retrieve all transactions for each player
    query = 'SELECT *  FROM '  + table + ' WHERE name="' + str(name) + '"' + 'ORDER BY date, type'
    try:
        cursor.execute(query)
    except MySQLdb.Error, e:
        print "Error in QUERY", query
        raw_input("press any key to continue")
    db.commit()
    player_transactions = cursor.fetchall()
    return player_transactions

def filter_players(all_players,threshold_file):
    t_players =  [line.rstrip('\n') for line in open(threshold_file,'r')]
    return list(set(all_players).intersection(set(t_players)))

def select_action():
    random_dice = random.random()

    if random_dice < 1/3:
        MLEaction = 0
    elif 1/3 <= random_dice < 2/3:
        MLEaction = 1
    else:
        MLEaction = 2

    return MLEaction

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''


# Read the stocks previously classified according to their risk
stock_risk = read_stock_file("../../data/risk_classified_stocks_3.txt")

# connect to DB and get the cursor and the db
cursor_and_db = connect_DB('localhost', 'root', 'root', 'virtualtrader')
cursor = cursor_and_db[0]
db     = cursor_and_db[1]

# retrieve players
players = filter_players(select_players('transactions', cursor, db),'players_threshold')

print 'Version 0.1'
print 'total players: ' + str(len(players))



rewards = dict()
actions = list()

randomMLEs = dict()

for player in players:

    print player
    #actions[player] = dict()

    # retrieve the transactions for each player
    transactions = select_transactions('transactions', player, cursor, db)

    # store the stocks purchased for future estimation of reward
    portfolio = dict()

    actions_amount = 0
    correct_actions = 0
    for transaction in transactions:

        # get only buy/sell actions
        if 'Buy' in transaction[3] or 'Sell' in transaction[3]:

            name        = str(transaction[1])
            date_string = str(transaction[2]).split(' ')[0].replace('-',' ')
            date        = datetime.strptime(date_string,'%Y %m %d')
            type        = str(transaction[3])
            stock       = str(transaction[4])
            volume      = int(transaction[5])
            price       = float(transaction[6])
            total       = float(transaction[7])

            if 'Buy' in type and stock:
                # save the stocks that have been purchased
                if stock in portfolio:
                    old_volume = portfolio[stock][0]
                    old_price  = portfolio[stock][1]
                    old_total  = portfolio[stock][2]
                    new_volume = volume + old_volume
                    new_price  = ((price * volume) + (old_volume * old_price)) / (volume + old_volume)
                    new_total  = old_total + (price * volume)
                    portfolio[stock] = (new_volume, new_price, new_total)
                else:
                    portfolio[stock] = (volume, price, total)

                # deduct money spent to purchase stock
                # (+ sign because the sign of the total is negative for purchases)

            elif 'Sell' in type and stock:

                if stock not in portfolio:
                    print ':::::::::::::::::::::::::::::::::::::::::::::::'
                    print player
                    print 'stock', stock
                    print 'portfolio', portfolio
                    # messed up player
                    break
                else:
                    actions_amount += 1

                    old_volume = portfolio[stock][0]
                    old_price  = portfolio[stock][1]
                    old_total  = portfolio[stock][2]

                    '''
                    # the reward is the gain on the price times the number of shares sold
                    reward = round(((price - old_price) * volume),0)

                    if reward in rewards:
                        rewards[reward] += 1
                    else:
                        rewards[reward] = 1
                    '''

                    # select the action really picked by player
                    action = stock_risk[stock]

                    correct_actions_temp = 0
                    repetitions = 100000
                    for i in xrange(repetitions):
                        random_action = select_action()

                        # Precision calculation (counting correctly predicted actions)
                        if random_action == action:
                            correct_actions_temp += 1

                    #print 'correct_actions_temp',correct_actions_temp
                    correct_actions += correct_actions_temp / repetitions
                    #print 'correct_actions',correct_actions
                    #print 'actions_amount',actions_amount
                    #raw_input()

    actions.append((player, correct_actions/actions_amount , actions_amount))



#rewards_file = open('histogram_rewards.csv','w')
actions_file = open('histogram_actions_nostring.csv','w')
#print str(len(rewards))
#for r in sorted(rewards):
#    print str(int(r)) + ' ' +  str(rewards[r])
    #rewards_file.write(str(int(r)) + ' , ' +  str(rewards[r]) + '\n')


for t in sorted(actions, key=lambda tup: tup[2]):
    print t
    #actions_file.write(str(players.index(t[0]))+' , ' +str(t[1]) + ' , ' + str(t[2]) + '\n')

#for p in sorted(actions.values(), key=operator.itemgetter(1)):
#    print p
#    print p[0]
#    print p[1]
#    print p[2]
#    raw_input()
#    print str(p[0]) + ' ' + str(p['total']) + ' ' + str(p['precision'])
#    actions_file.write(str(p[0]) + ' , ' + str(p[1]['total']) + ' , ' +  str(p[1]['precision']) + '\n')

#for act in actions:
#    print str(act) + ":" + str(actions[act]['precision']) + " vs " + str(actions[act]['total'])


#rewards_file.close()
actions_file.close()
close_DB()


