from __future__ import division
import os
import sys
import numpy as np
import operator


''' FUNCTIONS '''
# generator of chunks for the bins


def chunks(l, n):
    # generator of chunks for the bins
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i: i + n]

''' MAIN '''
# date of last transactions 27 May 2014

betas = {
    'Aberdeen Asset Management Plc':    1.8614156817,
    'Admiral Group Plc':                0.5677173239,
    'Aggreko':                          0.9061661826,
    'AMEC Plc':                         0.7754271385,
    'Anglo American Plc':               1.6083863742,
    'Antofagasta':                      1.2860471699,
    'ARM Holdings':                     1.4126180292,
    'Associated British Foods Plc':     0.819480559,
    'AstraZeneca Plc':                  0.8817006393,
    'Aviva Plc':                        1.1271771642,
    
    'Babcock Intl Group':               0.8458361138,
    'BAE Systems':                      0.8899012936,
    'Barclays':                         1.2162389824,
    'BG Group Plc':                     1.0056197711,
    'BHP Billiton Plc':                 1.2874561247,
    'BP':                               0.7765248881,
    'British American Tobacco Plc':     0.9575322851,
    'British Land':                     1.0295616638,
    'British Sky Broadcasting Group':   0.6175341974,
    'BT Group Plc':                     0.8578545517,
    'Bunzl':                            0.8079571683,
    'Burberry Group':                   1.1473023889,
    
    'Capita':                           0.7089004172,
    'Carnival Plc':                     0.8777041034,
    'Centrica Plc':                     0.4548895494,
    'Coca-Cola HBC':                    0.8463056342,
    'Compass Group Plc':                0.9545771072,
    'CRH':                              1.5074225408,
    'Croda International':              0.8624918349,
    
    'Diageo Plc':                       1.001026094,
    #Eurasian Natural Resources
    'Evraz':                            1.7036776375,
    'Experian':                         1.0023507996, 
    'easyJet Plc':                      1.4426536902,   
    
    'Friends Life Group':               0.8986384023,  
    'Fresnillo Plc':                    1.0193285115,
    
    'G4S Plc':                          0.5221777982,
    'GKN':                              1.4310022279,
    'GlaxoSmithKline':                  0.8326092352,
    'Glencore':                         1.3692098468,
    
    'Hammerson':                        1.0180111205,
    'Hargreaves Lansdown Plc':          1.1309634258,
    'HSBC Holdings Plc':                1.0683109824,
    
    'IMI':                              1.0062208533,
    'Imperial Tobacco':                 0.557887117,
    'InterContinental Hotels Group':    1.0832355751,
    'International Consolidated Airlines Group Plc':   1.3851118667,    #International Consolidated Airlines Group Plc
    'Intertek Group':                   0.7406525048,
    'ITV Plc':                          1.1714598299,
    'Intu Properties':                  0.8625788155,
    
    'Johnson Matthey':                  0.8620659572,
    
    'Kazakhmys Plc':                    0.1313617422,
    'Kingfisher':                       1.1109288264,
    
    'Land Securities Group':            1.0002726287,
    'Legal & General':              1.0850554697,
    'Lloyds Banking Group Plc':         1.1061522366,
    'London Stock Exchange Group':      1.0850460656, 
      
    'Marks&Spencer Group':          0.9915195102,
    'Meggitt Plc':                      0.8426412696,
    'Melrose Industries':               1.1971070228,
    'Morrison Wm Supermarkets':         0.6583179962,
    'Mondi Plc':                        1.5285909052,
       
    'National Grid Plc':                0.7471046185,
    'Next':                             0.720828775,
    
    'Old Mutual':                       1.3897716938,
    
    'Pearson':                          0.6353953245,
    'Petrofac Ltd':                     1.087499972,
    'Prudential':                       1.3992887549,
    'Persimmon':                        1.4858898003,   
    'Polymetal International':          1.618726551,
    
    'Randgold Resources Ltd':           0.6393535099,
    'Reckitt Benckiser Group':          0.7887921371,
    'Reed Elsevier Plc':                0.7217709456,
    #Resolution Limited
    'Rexam Plc':                        0.9489492426,   
    'Rio Tinto':                        1.3823701646,
    'Rolls-Royce Holding':              0.9638049024,
    'Royal Bank of Scotland Group':     1.4694466032,
    'Royal Dutch Shell-A Shs':          0.7362021841,    
    'Royal Dutch Shell-B Shs':          0.7250991694,
    'RSA Insurance Group Plc':          0.5912553301,
    
    'SABMiller Plc':                    1.233756255,
    'Sage Group Plc':                   0.7748102997,
    'Sainsbury (J.)':                   0.7032831712,
    'Schroders Plc':                    1.3571141423,
    'Serco Group':                      0.3961846876,
    'Severn Trent':                     0.6577750017,   
    'Shire Plc':                        1.0270952984,
    'Smith & Nephew':               0.8055034833,
    'Smiths Group Plc':                 0.9857029494,
    'SSE':                              0.5091014583,
    'Standard Chartered':               1.2781790058,
    'Standard Life Plc':                1.3642416864,
    'Sports Direct International Plc':   0.9829517882,
       
    'Tate & Lyle':                  0.8082734292,
    'Tesco':                            0.7880015691,
    'TUI Travel Plc':                   1.1352705265,
    'Tullow Oil Plc':                   0.9462655357,
    'Travis Perkins Plc':               1.2630323355,   #not in FTSE100
    'Unilever':                         0.9727825879,
    'United Utilities Group':           0.6196763053,
    'Vedanta Resources Plc':            1.4892322229,
    'Vodafone Group Plc':               0.9261171421,
    'Weir Group':                       1.0583879707,    
    "Whitbread A":                    1.0901994939,
    'Wolseley':                         1.2198770193,
    'Wood Group (John)':                1.0737378523,
    'WPP Plc':                          1.2424510311,
    'William Hill':                     1.0393957408,   #not in FTSE100
    #Xstrata
}

all_stock = {}
highest_std = 8582946964.77
rootdir    = sys.argv[1]
binsAmount = int(sys.argv[2])

bins = {i: [] for i in xrange(binsAmount)}

for folder, subs, files in os.walk(rootdir):

    for fileName in files:
        if "csv" in fileName:
            companyName = fileName[:-4]
            print "file:", companyName

            with open(os.path.join(folder, fileName), 'r') as dataFile:

                # create a list of points (close value)
                content = dataFile.readlines()
                closePoints = (companyName, [])
                
                # 1:   remove first line (description of columns)
                # 250: get the close prices of the past year (sometimes history might not be enough to get to 250)
                for line in content[1:250]: 
                    line = line.split(",")
                    
                    # multiply closing price by volume so splits do not affect directly the statistics
                    closePrice = float(line[4])
                    volume = int(line[5])
                    capitalization = closePrice * volume
                    # create a list of tuples (date, capitalization)
                    closePoints[1].append((line[0], capitalization))

                # this is the list of cap values
                # zip creates two lists according to the tuples: date list and cap list (TODO  remove the dates? )
                cap = np.asarray(zip(*closePoints[1])[1])
                stddev = np.std(cap, ddof=1)
                print stddev / highest_std
                print
                
                # code was run the first time to estimate the highest std dev (8582946964.77)
                # highest_std = max([stddev,highest_std]) estimate highest stdev (to normalise)
                
                # TODO improve the measure including a moving window of the return average
                # ## oneYearPrice = float(content[250].split(",")[4])    #date corresponds to 30-May-2013
                # ## lastPrice = float(content[1].split(",")[4])
                
                # the rate of gain (positive or negative) is defined as the difference of the 
                # current price with the price one year ago divided by the old price
                # (alternatively the rate of gain can be defined as current / year -1)
                # ##gainRate = (lastPrice - oneYearPrice) / (oneYearPrice)
                # print "gain rate:",gainRate
                
                # riskiness is the absolute value of the combination of beta of the company
                # and std dev of the price in the last three years
                riskiness = abs(betas[companyName] * stddev / highest_std)
                
                # pool of all stocks riskiness to plot distribution
                all_stock[companyName] = riskiness

                ''' This unbalances the bins size
                # extends to all number of bins
                # riskiness into j-th bin if in range [j/N, j+1/N]
                for j in xrange(binsAmount + 1):
                    if j / binsAmount < riskiness  < (j + 1) / binsAmount:
                                bins[j].append((companyName, riskiness))

                '''

# sort all the stocks according to their riskiness
sorted_stocks = sorted(all_stock.items(), key=operator.itemgetter(1))
print sorted_stocks


stock_bins = list(chunks(sorted_stocks, int(round(len(sorted_stocks) / binsAmount))))
#for item in separated:
#    for jtem in item:
#        print jtem
#    print

#print len(sorted_stocks)
#print sum([len(item) for item in separated])


outFile = open(rootdir + "risk_classified_stocks_uniform" + str(binsAmount) + ".txt", "w")

for stock_bin in stock_bins:
    outFile.write(str(len(stock_bin)) + '\n')
    for item in stock_bin:
        outFile.write(str(item[0]) + '\t' + str(item[1]) +'\n')

outFile.close()


'''
for i in sorted(bins.keys()):
    print '\nrisk class ' + str(i) + '\n'
    outFile.write('\nrisk class ' + str(i) + '\n')
    # print bins[i]
    # raw_input()
    for c in sorted(bins[i], key=lambda risk: risk[1]):
        print c
        outFile.write((str(c[0]) + '~' + str(c[1]) + '\n'))

'''


