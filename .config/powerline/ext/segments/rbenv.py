# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import re
from powerline.theme import requires_segment_info
from powerline.lib.shell import run_cmd

@requires_segment_info
def rbenv(pl, segment_info, format='{version}'):
	version = run_cmd(pl, 'rbenv version-name', strip=True)
	return [] if version is None else [{
		'contents': format.format(version=version),
		'highlight_groups': ['rbenv', 'user'],
		}]
