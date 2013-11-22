# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import re

from powerline.theme import requires_segment_info

@requires_segment_info
def ref_perldoc_module(pl, segment_info):
	name = segment_info['buffer'].name
	pl.info(name)
	if not name: return ''

	module = re.compile(r'\[ref-perldoc:(.*)\]')
	m = re.match(module, name)
	if not m: return ''

	pl.info(m.group(1))
	return m.group(1)
