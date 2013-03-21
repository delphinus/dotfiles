# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

from __future__ import absolute_import

import json
import sys
import os

class NowPlayingSegment(object):
	STATE_SYMBOLS = {
		'fallback': u'♫',
		'play': u'▶',
		'pause': u'▮▮',
		'stop': u'■',
		}

	def __call__(self, player='mpd', format='{state_symbol} {artist} - {title} ({total})', *args, **kwargs):
		player_func = getattr(self, 'player_{0}'.format(player))
		stats = {
			'state': None,
			'state_symbol': self.STATE_SYMBOLS['fallback'],
			'album': None,
			'artist': None,
			'title': None,
			'elapsed': None,
			'total': None,
			}
		func_stats = player_func(*args, **kwargs)
		if not func_stats:
			return None
		stats.update(func_stats)
		return format.format(**stats)

	@staticmethod
	def _run_cmd(cmd):
		from subprocess import Popen, PIPE
		try:
			p = Popen(cmd, stdout=PIPE)
			stdout, err = p.communicate()
		except OSError as e:
			sys.stderr.write('Cloud not execute command ({0}): {1}\n'.format(e, cmd))
			return None
		return stdout.strip()

	def player_lastfm(self):
		now_playing_str = self._run_cmd([os.environ.get('MYPERL'),
				os.path.expanduser('~/git/dotfiles/.screen/lastfm-json.pl')])
		data = json.loads(now_playing_str)
		return {
				'state': 'fallback' if data.get('playing') == 'played' else 'play',
				'artist': data.get('artist'),
				'title': data.get('title'),
				'elapsed': data.get('timestamp'),
				}
now_playing = NowPlayingSegment()

if __name__ == '__main__':
	sys.stdout.write(now_playing(
		player = 'lastfm',
		format = '{state_symbol} {artist} - {title} ({elapsed})',
		))
