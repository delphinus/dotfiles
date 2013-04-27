# -*- encoding: utf-8 -*-
# vim:se noet:

from __future__ import absolute_import

import os

def unite(matcher_info):
	name = matcher_info['buffer'].name
	return name and os.path.basename(name).find('*unite*') == 0
