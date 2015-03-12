__author__ = 'alvin'
import operator

with open('lev2') as temp_file:
  text = [line.rstrip('\n') for line in temp_file]

text = ''.join(text)

chars = {}
for c in text:
    if c not in chars:
        chars[c] = 1
    else:
        chars[c] +=1

print sorted(chars.items(),key=operator.itemgetter(1))


