#!/usr/bin/python

import os
import sys
import subprocess
import anydbm
import pickle

if len(sys.argv) < 2:
   print "Usage:"
   print "{0} <db-file> [-v]\n".format(sys.argv[0])
   sys.exit(1)

db_file = sys.argv[1]

if len(sys.argv) == 3 and sys.argv[2] == '-v':
    verbose = True
else:
    verbose = False

if not db_file.endswith('.dbm'):
   print "Expecting .dbm file"
   sys.exit(1)

db = anydbm.open(db_file, 'r')

count = 0

for k in db.keys():

  count += 1

  if verbose:
     print k

db.close()

print 'Total: ', count
