#!/usr/bin/python

import subprocess
import json
import sys

FFMPEG='/usr/bin/ffprobe'
SAR='sample_aspect_ratio'

if len(sys.argv) != 2:
    raise Exception('Usage: <filename>')

FILENAME = sys.argv[1]

cmd = [ FFMPEG, '-hide_banner', '-print_format', 'json', '-show_streams',
        '-select_streams', 'v', '-loglevel', 'error', FILENAME]

j = subprocess.check_output(cmd)

info = json.loads(j)

for s in info['streams']:
    if SAR not in s:
        raise Exception('Missing {0} attribute'.format(SAR))
    print s[SAR]
