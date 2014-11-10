# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:
from __future__ import (unicode_literals, division, absolute_import, print_function)

import os
import re
try:
	import vim
except ImportError:
	vim = {}

from powerline.bindings.vim import vim_get_func, getbufvar
from powerline.theme import requires_segment_info

vim_funcs = {
		'col': vim_get_func('col', rettype=int),
		'virtcol': vim_get_func('virtcol', rettype=int),
		'getcwd': vim_get_func('getcwd'),
		'fnamemodify': vim_get_func('fnamemodify'),
		}

def _do_ex(command):
	'''Execute Ex command.

	Execute Ex command from args and return results string.
	'''
	vim.command('redir => tmp_do_ex | silent! {0} | redir END'.format(command))
	return vim.eval('tmp_do_ex')

def col_current_virt(pl, gradient=True):
	'''Return the current cursor column.

	Since default 'col_current()' function returns current OR virtual column
	only, this function returns current AND virtual columns.
	'''
	virtcol = str(vim_funcs['virtcol']('.'))
	col = str(vim_funcs['col']('.'))
	res = [{'contents': col if virtcol == col else col + '-' + virtcol,
		'highlight_group': ['virtcol_current', 'col_current']}]
	if gradient:
		textwidth = int(getbufvar('%', '&textwidth'))
		res[-1]['gradient_level'] = min(int(virtcol) * 100 / textwidth, 100) \
				if textwidth else 0
		res[-1]['highlight_group'].insert(0, 'virtcol_current_gradient')
	return res

def get_char_code(pl):
	'''Return charcode and char itself on cursol position.

	port from vim-powerline
	'''
	info = _do_ex('ascii')

	if info == '' or info.find('NUL') != -1:
		return 'NUL'

	fenc = vim.eval('&fileencoding')
	nrformat = "'{}' " + ('{:#06x}' if fenc == 'utf-8' else '{:#04x}')

	# Get the character and the numeric value from the return value of :ascii
	# This matches the two first pieces of the return value, e.g.
	# "<F>  70" => char: 'F', nr: '70'
	m = re.compile(r'<(.+?)>\s*(\d+)').search(info)

	if m == None:
		return 'NUL'
	else:
		char, code = m.groups()
		code = int(code)
		return nrformat.format(char, code)

@requires_segment_info
def current_directory(pl, segment_info, shorten_user=True, shorten_cwd=True, shorten_home=False):
	'''Return current directory.

	:param bool shorten_user:
		shorten ``$HOME`` directory to :file:`~/`

	:param bool shorten_home:
		shorten all directories in :file:`/home/` to :file:`~user/` instead of :file:`/home/user/`.
	'''
	current_directory = vim_funcs['fnamemodify'](vim_funcs['getcwd'](),
			(':~' if shorten_user else '') + (':h' if shorten_home else ''))
	pl.info(current_directory)
	if shorten_home and current_directory.startswith('/home/'):
		current_directory = '~' + current_directory[6:]
	return current_directory + os.sep if current_directory else None
