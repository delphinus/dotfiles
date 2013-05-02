# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

from powerline.bindings.vim import vim_get_func

def unite_status_string(pl):
	return vim_get_func('unite#get_status_string')()
