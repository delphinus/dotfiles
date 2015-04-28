# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:
from __future__ import (unicode_literals, division, absolute_import, print_function)

try:
	import vim
except ImportError:
	vim = {}

from powerline.bindings.vim import vim_get_func

def webdevicons(pl):
	get_icon = vim_get_func('WebDevIconsGetFileTypeSymbol')
	return [] if not get_icon else [{
		'contents': get_icon().decode('utf-8') + ' ',
		'highlight_groups': ['webdevicons', 'file_name'],
		}]
