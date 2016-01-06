# vim:fileencoding=utf-8:noet
from __future__ import (unicode_literals, division, absolute_import, print_function)

from powerline.bindings.vim import (buffer_name, vim_get_func)
from powerline.lib.vcs import guess
from powerline.theme import (requires_filesystem_watcher, requires_segment_info)

import re
import os

try:
	import vim
except ImportError:
	vim = object()

vim_funcs = {
		'fnamemodify': vim_get_func('fnamemodify', rettype='bytes'),
		'getcwd': vim_get_func('getcwd')
		}

SCHEME_RE = re.compile(b'^\\w[\\w\\d+\\-.]*(?=:)')

@requires_filesystem_watcher
@requires_segment_info
def repo_directory(pl, segment_info, create_watcher):
	name = buffer_name(segment_info)
	file_directory = vim_funcs['fnamemodify'](name, ':h')
	if not name:
		return None
	match = SCHEME_RE.match(name)
	if match:
		repo_directory = file_directory
	else:
		repo = guess(path=name, create_watcher=create_watcher)
		if repo is not None:
			directory_to_sub = vim_funcs['fnamemodify'](repo.directory, ':h:h') + os.sep
			repo_directory = repo.directory
		else:
			repo_directory = vim_funcs['fnamemodify'](name, ':h')
			directory_to_sub = vim_funcs['fnamemodify'](repo_directory, ':h:h')
			if directory_to_sub != '/':
				directory_to_sub = directory_to_sub + os.sep
		repo_directory = repo_directory[len(directory_to_sub):]
	repo_directory = repo_directory.decode(segment_info['encoding'], 'powerline_vim_strtrans_error')
	return [{
		'contents': repo_directory,
		'highlight_groups': ['repo_directory', 'file_name'],
		}]
