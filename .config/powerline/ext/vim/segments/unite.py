# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import re
from powerline.bindings.vim import vim_get_func

def sources(pl):
	status_string = parse_status_string()
	return [] if 'sources' not in status_string else [{
		'contents': status_string['sources'],
		'highlight_groups': ['unite_sources', 'file_name'],
		}]

def status(pl):
	status_string = parse_status_string()
	return [] if 'status' not in status_string else [{
		'contents': status_string['status'],
		'highlight_groups': ['unite_sources', 'file_format'],
		}]

def parse_status_string():
	status = vim_get_func('unite#get_status_string')()
	try:
		sources, status = re.compile(r' \| ').split(status)
	except ValueError:
		return {}
	return {
			'sources': sources,
			'status':  status,
			}
