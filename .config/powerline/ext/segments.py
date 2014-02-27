# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import re

import powerline.segments.common;
from powerline.theme import requires_segment_info

@requires_segment_info
def hostname(pl, segment_info, only_if_ssh=False, exclude_domain=False):
	'''Return the current hostname.

	copy from segments.common.hostname
	'''
	hostname = powerline.segments.common.hostname(
			pl, segment_info, only_if_ssh, exclude_domain)
	p = re.compile(r'\S*?(?=\d+$)')
	return p.sub('', hostname)
