#!/usr/bin/env python

from __future__ import absolute_import

import math
import os
import re

filename = '/tmp/last-message-history.log'

f = open(filename, 'r')
filesize = os.path.getsize(filename)
bufsize = 4
pos = int(math.ceil(float(filesize) / bufsize))

buf_tmp = ''
tail = []
num = 1
while pos:
    f.seek(bufsize * pos)
    buf = f.read(bufsize) + buf_tmp
    matches = re.findall(r'[^\x0D\x0A]*\x0D?\x0A?', buf)
    lines = []
    for i in xrange(len(matches)):
        if i == 0:
            buf_tmp = matches[i]
        else:
            lines.append(matches[i])

    if len(lines):
        lines.pop()
        tail[1:1] = lines

    if len(tail) > num:
        break
    else:
        pos -= 1

if len(tail) > num:
    tail = tail[-num:]
