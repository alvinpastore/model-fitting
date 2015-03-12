from operator import indexOf

__author__ = 'alvin'

from string import maketrans

alphabet = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
a2 = []

for i in xrange(len(alphabet)):
    if i+2< len(alphabet):
        a2.append(alphabet[i+2])
    else:
        k = i - len(alphabet) + 2
        a2.append(alphabet[k])

print a2
alphabet = ''.join(alphabet)
a2 = ''.join(a2)

message = "g fmnc wms bgblr rpylqjyrc gr zw fylb. rfyrq ufyr amknsrcpq ypc dmp. bmgle gr gl zw fylb gq glcddgagclr ylb rfyr'q ufw rfgq rcvr gq qm jmle. sqgle qrpgle.kyicrpylq() gq pcamkkclbcb. lmu ynnjw ml rfc spj."

'''
m2 = []
for c in message:
    if c in a2:
        m2.append(a2[alphabet.index(c)])
    else:
        m2.append(c)
'''

trantab = maketrans(alphabet,a2)

print message.translate(trantab)
print 'map'.translate(trantab)
#print ''.join(m2)
