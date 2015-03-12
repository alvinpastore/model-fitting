__author__ = 'alvin'

import zipfile
zfile = zipfile.ZipFile('channel.zip','r')

file_number = '90052'
comments = []

while file_number.isdigit():
    comments.append(zfile.getinfo(file_number+'.txt').comment)

    infile = zfile.open(file_number + '.txt')
    file_number = infile.readline().split(' ')[-1]

    #comments.append(zfile.getinfo(file_number+'.txt').comment)

print ''.join(comments)