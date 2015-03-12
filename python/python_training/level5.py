__author__ = 'alvin'

import pickle
import urllib2

response = urllib2.urlopen('http://www.pythonchallenge.com/pc/def/banner.p')
html = response.read()
test = pickle.loads(html)

for line in test:
    print "".join(i[0] * i[1] for i in line)
    #print line
