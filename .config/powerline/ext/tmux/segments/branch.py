# vim:fileencoding=utf-8:noet

from __future__ import absolute_import

from powerline.lib.vcs import guess, tree_status
from powerline.theme import requires_segment_info

@requires_segment_info
def branch(pl, segment_info, status_colors=False, path=None):
	'''Return the current VCS branch in specified directory.

	:param bool status_colors:
		determines whether repository status will be used to determine highlighting. Default: False.
	:param string path:
		determines which directory will be watched.
		current directory will be set if this is None. Default: None.

	Highlight groups used: ``branch_clean``, ``branch_dirty``, ``branch``.
	'''
	if path is None: path = segment_info['getcwd']()
	repo = guess(path=path)
	if repo is not None:
		branch = repo.branch()
		scol = ['branch']
		if status_colors:
			status = tree_status(repo, pl)
			scol.insert(0, 'branch_dirty' if status and status.strip() else 'branch_clean')
		return [{
			'contents': branch,
			'highlight_group': scol,
		}]

