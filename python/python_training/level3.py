__author__ = 'alvin'

import re
from collections import Counter

with open('lev3') as temp_file:
    text = [line.rstrip('\n') for line in temp_file]

text = ''.join(text)

'''
chars = []
for i in xrange((len(text)-2)):
    if text[i+1] == text[i] and text[i+2] == text[i]:
        chars.append(text[i+3])
print chars
'''


chars = []

groups = re.findall(r"([^A-Z])([A-Z]{3})([a-z])([A-Z]{3})([^A-Z])",text)
for group in groups:
    chars.append(group[2])
print chars
#regexp = re.compile(r"([A-Z])\1\1")
#regexp2 =re.compile(r"([A-Z])\1\1.([A-Z])\1\1")

