__author__ = 'alvin'
import urllib2

def get_code(incode):
    response = urllib2.urlopen('http://www.pythonchallenge.com/pc/def/linkedlist.php?nothing='+str(incode))
    html = response.read().split(' ')
    outcode = html[len(html)-1]
    print outcode
    return outcode

code = '12345'
i = 1
while True:
    code = get_code(code)
    i+=1

print i


#http://www.pythonchallenge.com/pc/def/linkedlist.php?nothing=71331
