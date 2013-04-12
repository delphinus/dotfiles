#!/usr/bin/env python
# -*- encoding-utf-8 -*-

from __future__ import absolute_import

from urllib import urlencode, urlopen
import sys

if len(sys.argv) < 2:
    quit()

url = 'http://127.0.0.1:18080'
q = {'message': sys.argv[1].decode('CP932').encode('UTF-8')}
urlopen(url, urlencode(q))
