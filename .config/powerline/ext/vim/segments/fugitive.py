# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import re

from powerline.theme import requires_segment_info

@requires_segment_info
def fugitive_hash(pl, segment_info):
	name = segment_info['buffer'].name
	if not name:
		return ''

	prog = re.compile(r'\.git//([0-9a-fA-F]{8,})')
	m = re.search(prog, name)
	if not m:
		return ''

	return m.group(1)[0:8]
