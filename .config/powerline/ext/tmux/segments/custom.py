# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import sys

STATE_SYMBOLS = {
	'fallback': '♫',
	'play': '▶',
	'pause': '▮▮',
	'stop': '■',
	}

def _run_cmd(cmd):
	from subprocess import Popen, PIPE
	try:
		p = Popen(cmd, stdout=PIPE)
		stdout, err = p.communicate()
	except OSError as e:
		sys.stderr.write('Cloud not execute command ({0}): {1}\n'.format(e, cmd))
		return None
	return stdout.strip()

def lastfm_playing(format='{state_symbol} {artist} - {title} ({total})', *args, **kwargs):
	now_playing_str = _run_cmd(['$H/git/dotfiles/.screen/lastfm.pl'])
	return now_playing_str
