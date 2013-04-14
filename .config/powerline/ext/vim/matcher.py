# -*- encoding: utf-8 -*-
# vim:se noet:

from __future__ import absolute_import

import re

def unite(matcher_info):
	name = matcher_info['buffer'].name
	return name and re.match(r'^\*unite\* - ', name) != None
