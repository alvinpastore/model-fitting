from DatabaseHandler import DatabaseHandler
from datetime import datetime


def filter_players(all_players, threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))


db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

# retrieve players
db_players = db.select_players('transactions')
players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

with open('../../data/players_transactions.csv', 'w') as transactions_file:
    for player in players:

        print '\n' + str(players.index(player)) + ' : ' + str(player)
        transactions_file.write('\n' + str(players.index(player)))
        # retrieve the transactions for each player
        transactions = db.select_transactions('transactions', player)
        for transaction in transactions:
            # get only buy/sell actions
            if 'Buy' in transaction[3] or 'Sell' in transaction[3]:

                name = str(transaction[1])
                date_string = str(transaction[2]).split(' ')[0].replace('-', ' ')
                date = datetime.strptime(date_string, '%Y %m %d')
                a_type = str(transaction[3])
                stock = str(transaction[4])

                if 'Sell' in a_type and stock:
                    print stock
                    transactions_file.write(',' + stock)
