import os
import sys
import numpy as np
import operator
''' FUNCTIONS '''

def validateData(values):
    compare_value = values[0]
    for i in range(1,len(values)):
        a=2
        #if value

''' MAIN '''
# date of last transactions 27 May 2014
rootdir = sys.argv[1]


for folder, subs, files in os.walk(rootdir):

    for fileName in files:
        if "csv" in fileName:
            companyName = fileName[:-4]
            print "file:",companyName

            with open(os.path.join(folder,fileName), 'r') as dataFile:
                
                
                # create a list of points (close value)
                content = dataFile.readlines()
                closePoints = (companyName,[])
                
                # 1:   remove first line (description of columns)
                # 250: get the close prices of the past year (sometimes history might not be enough)
                for line in content[1:250]: 
                    line = line.split(",")
                    
                    # multiply closing price by volume so splits do not affect directly the statistics
                    closePrice = float(line[4])
                    volume = int(line[5])/1000
                    price_x_volume = closePrice * volume
                    
                    # create a list of tuples (date, ppv)
                    closePoints[1].append((line[0],price_x_volume))

                #this is the list of ppv values 
                #zip creates two lists according to the tuples: date list and ppvs list (check if can remove the dates)
                ppvs = np.asarray(zip(*closePoints[1])[1])
                                                                
                #TODOvalidateData(ppvs) 
                
                for e in ppvs:
                    print e
                    raw_input()                                                       
             
                

                    
  
                
