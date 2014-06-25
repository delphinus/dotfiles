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

@requires_segment_info
def mode(pl, segment_info, override={'vicmd': 'COMMND', 'viins': 'INSERT'}, default=None):
	mode = segment_info['environ'].get('_POWERLINE_MODE')
	if not mode:
		pl.debug('No or empty _POWERLINE_MODE variable')
		return None
	default = default or segment_info['environ'].get('_POWERLINE_DEFAULT_MODE')
	if mode == default:
		return None
	try:
		return override[mode]
	except KeyError:
		return mode.upper()
