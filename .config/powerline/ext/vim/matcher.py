# -*- encoding: utf-8 -*-
# vim:se noet:

from __future__ import absolute_import

import os
try:
	import vim
except ImportError:
	vim = {}  # NOQA

from powerline.bindings.vim import vim_getbufoption

def unite(matcher_info):
	return vim_getbufoption(matcher_info, 'filetype') == 'unite'

def calendar(matcher_info):
	name = matcher_info['buffer'].name
	return name and os.path.basename(name).find('__Calendar__') == 0

def vimshell(matcher_info):
	return vim_getbufoption(matcher_info, 'filetype') == 'vimshell'

def iexe_mysql(matcher_info):
	name = matcher_info['buffer'].name
	return name and name.find('iexe-mysql') >= 0
