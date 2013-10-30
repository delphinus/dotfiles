# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import os
import re

from powerline.theme import requires_segment_info

@requires_segment_info
def mysql_server(pl, segment_info):
	return _get_info(pl, segment_info)[0]

@requires_segment_info
def mysql_user(pl, segment_info):
	return _get_info(pl, segment_info)[1]

@requires_segment_info
def mysql_db(pl, segment_info):
	return _get_info(pl, segment_info)[2]

def _get_info(pl, segment_info):
	name = segment_info['buffer'].name
	if not name:
		return ('', '', '')

	prog = re.compile(r'^iexe-mysql -A -h(.*) -u(.*) (.*)$')
	m = re.match(prog, os.path.basename(name))
	if not m:
		return ('', '', '')

	return m.groups()
