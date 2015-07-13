# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:
from __future__ import (unicode_literals, division, absolute_import, print_function)

try:
	import vim
except ImportError:
	vim = object()

from powerline.bindings.vim import vim_get_func

def is_active(pl, word='Table'):
	'''Show status for vim-table-mode

	:param str word:
		A string displayed when table-mode is active.

	Highlight groups used ``table_mode`` or ``line_current``.
	'''

	try:
		is_active = int(vim_get_func('tablemode#IsActive')()) == 1
	except:
		is_active = False

	return [] if not is_active else [{
		'contents': word,
		'highlight_groups': ['table_mode', 'paste_indicator'],
		}]
