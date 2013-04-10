# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import re
try:
	import vim
except ImportError:
	vim = {}

from powerline.bindings.vim import vim_get_func
from powerline.theme import requires_segment_info

vim_funcs = {
		'col': vim_get_func('col', rettype=int),
		'virtcol': vim_get_func('virtcol', rettype=int),
		}

def _do_ex(command):
	'''Execute Ex command.

	Execute Ex command from args and return results string.
	'''
	vim.command('redir => tmp_do_ex | silent! {0} | redir END'.format(command))
	return vim.eval('tmp_do_ex')

@requires_segment_info
def col_current_virt(pl, segment_info):
	'''Return the current cursor column.

	Since default 'col_current()' function returns current OR virtual column
	only, this function returns current AND virtual columns.
	'''
	virtcol = str(vim_funcs['virtcol']('.'))
	col = str(segment_info['window'].cursor[1] + 1)
	return [{'contents': col if virtcol == col else col + '-' + virtcol,
		'highlight_group': ['virtcol_current', 'col_current']}]

def get_char_code(pl):
	'''Return charcode and char itself on cursol position.

	port from vim-powerline
	'''
	info = _do_ex('ascii')

	if info == '' or info.find('NUL') != -1:
		return 'NUL'

	enc = vim.eval('&encoding')
	fenc = vim.eval('&fileencoding')
	info = info.decode(enc)
	nrformat = u"'{}' " + (u'{:#06x}' if fenc == 'utf-8' else u'{:#04x}')

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
