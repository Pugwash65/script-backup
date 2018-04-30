#!/usr/bin/python

import os
import sys
import subprocess
import anydbm
import pickle

if len(sys.argv) != 3:
   print "Usage:"
   print "{0} <db-file> <root-dir>\n".format(sys.argv[0])
   sys.exit(1)

db_file = sys.argv[1]

if not db_file.endswith('.dbm'):
   print "Expecting .dbm file"
   sys.exit(1)

root_dir = sys.argv[2]

if not os.path.isdir(root_dir):
   print "Root dir needs to be a directory"
   sys.exit(1)

if os.path.exists(db_file) and os.path.basename(root_dir) == 'Photos':
   print "Starting at Photos root with existing DB"
   sys.exit(1)

count = 0
db = anydbm.open(db_file, 'c') # Create

topdown = True

for root, dirs, files in os.walk(root_dir, topdown):
#  print "R: " + root
#  print 'D: ' + ' '.join(dirs)
#  print 'F: ' + ' '.join(files)

  if os.path.basename(root) == '.@__thumb':
      continue;

  print root

  for f in files:
    file = os.path.join(root, f)

    count += 1

    sum = subprocess.check_output(['/usr/bin/md5sum', file], shell=False)
    sum = sum[:32]
    if sum in db:
 	s = db[sum]
 	x = pickle.loads(s)
    else:
  	x = []

    x.append(file)
    s = pickle.dumps(x)
    db[sum] = s

print len(db.keys()), ' unique images out of ', count

db.close()
