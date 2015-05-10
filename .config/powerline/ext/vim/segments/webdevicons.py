# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:
from __future__ import (unicode_literals, division, absolute_import, print_function)

try:
	import vim
except ImportError:
	vim = {}

from powerline.bindings.vim import vim_get_func

def webdevicons(pl):
	webdevicons = vim_get_func('WebDevIconsGetFileTypeSymbol')
	return [] if not webdevicons else [{
		'contents': webdevicons(),
		'highlight_groups': ['webdevicons', 'file_name'],
		}]
