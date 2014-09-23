# -*- encoding: utf-8 -*-
# vim:se noet:

from __future__ import (unicode_literals, division, absolute_import, print_function)

import os

from powerline.bindings.vim import vim_getbufoption

def unite(matcher_info):
	return vim_getbufoption(matcher_info, 'filetype') == 'unite'

def gitcommit(matcher_info):
	return vim_getbufoption(matcher_info, 'filetype') == 'gitcommit'

def calc(matcher_info):
	return vim_getbufoption(matcher_info, 'filetype') == 'vimcalc'

def fugitive(matcher_info):
	name = matcher_info['buffer'].name
	return name and name.find('fugitive://') == 0

def calendar(matcher_info):
	name = matcher_info['buffer'].name
	return name and os.path.basename(name).find('__Calendar__') == 0

def vimshell(matcher_info):
	return vim_getbufoption(matcher_info, 'filetype') == 'vimshell'

def iexe_mysql(matcher_info):
	name = matcher_info['buffer'].name
	return name and os.path.basename(name).find('iexe-mysql') == 0

def ref_perldoc(matcher_info):
	return vim_getbufoption(matcher_info, 'filetype') == 'ref-perldoc'
