#!/usr/bin/python

### MAYBE CHECK path isn't already in database to allow a refresh

import os
import sys
import subprocess
import anydbm
import pickle

DB_DIR = 'data'
base_dir = os.path.dirname(os.path.abspath(__file__))
db_dir = os.path.join(base_dir, DB_DIR)
db_sum = os.path.join(db_dir, 'sums.dbm')
db_file = os.path.join(db_dir, 'files.dbm')

if len(sys.argv) != 2:
   print "Usage:"
   print "{0} <root-dir>\n".format(sys.argv[0])
   sys.exit(1)

root_dir = sys.argv[1]

if not os.path.isdir(root_dir):
   print "Root dir needs to be a directory"
   sys.exit(1)

count_scan = 0
count_store = 0
fh_sums = anydbm.open(db_sum, 'c') # Create
fh_files = anydbm.open(db_file, 'c') # Create

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

    count_scan += 1

    if file in fh_files:
       continue

    sum = subprocess.check_output(['/usr/bin/md5sum', file], shell=False)
    sum = sum[:32]
    if sum in fh_sums:
 	s = fh_sums[sum]
 	x = pickle.loads(s)
    else:
  	x = []

    x.append(file)
    s = pickle.dumps(x)
    fh_sums[sum] = s
    fh_files[file] = 't'

    count_store += 1
    
fh_sums.close()
fh_files.close()

print  'Stored {0} images out of {1}'.format(count_store, count_scan)

sys.exit(0)

