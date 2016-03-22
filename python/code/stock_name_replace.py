__author__ = 'alvin'
import os
import sys

rootdir = sys.argv[1]

print "folder " + str(rootdir)
for folder, subs, files in os.walk(rootdir):
    for fileName in files:
        if "uniform_random_3" in fileName and 'mod' not in fileName:
            print fileName
            with open(rootdir + '_mod/mod' + fileName , 'w') as fout:
                with open(rootdir + "/" + fileName, "r") as fin:
                    for line in fin:
                        new_line = line.replace("Whitbread A", "Whitbread 'A'").\
                            replace("&", "&amp;").\
                            replace("Sports Direct International Plc", "Sports Direct International Pl").\
                            replace("International Consolidated Airlines Group Plc", "International Consolidated Air")
                        fout.write(new_line)
                        if '&' in line:
                            print line
                            print new_line
