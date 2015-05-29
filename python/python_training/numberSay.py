__author__ = 'alvin'


def numSay(s):
    outs = ''
    i = 0
    while i < len(s):
        cur = s[i]
        acc = 1
        j = i + 1
        while j < len(s) and s[j] == cur:
            acc += 1
            i = j
            j += 1
        outs += str(acc) + str(cur)
        i += 1
    return outs

num_string = '1'

for k in xrange(19):
    num_string = numSay(num_string)
print num_string

