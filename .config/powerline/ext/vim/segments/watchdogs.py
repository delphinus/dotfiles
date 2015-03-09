# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:
from __future__ import (unicode_literals, division, absolute_import, print_function)

try:
	import vim
except ImportError:
	vim = object()

from powerline.segments.vim import window_cached
from powerline.bindings.vim import vim_get_func

@window_cached
def watchdogs(pl, err_format='ERR:  {first_line} ({num})'):
	'''Show whether watchdogs has found any errors

	:param str err_format:
		Format string for errors.

	Highlight groups used ``watchdogs:error`` or ``error``.
	'''

	bufnr = int(vim_get_func('bufnr')(''))
	errors = filter(lambda qf: qf['bufnr'] == bufnr, vim_get_func('getqflist')())

	return [] if len(errors) == 0 else [{
		'contents': err_format.format(first_line=errors[0]['lnum'], num=len(errors)),
		'highlight_groups': ['watchdogs:error', 'error']
		}]
