# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

import re

from powerline.lib.shell import asrun
import powerline.segments.common;
from powerline.theme import requires_segment_info

@requires_segment_info
def hostname(pl, segment_info, only_if_ssh=False, exclude_domain=False):
	'''Return the current hostname.

	copy from segments.common.hostname
	'''
	hostname = powerline.segments.common.hostname(
			pl, segment_info, only_if_ssh, exclude_domain)
	p = re.compile(r'\S*?(?=\d+$)')
	return p.sub('', hostname)

@requires_segment_info
def mode(pl, segment_info, override={'vicmd': 'COMMND', 'viins': 'INSERT'}, default=None):
	mode = segment_info['environ'].get('_POWERLINE_MODE')
	if not mode:
		pl.debug('No or empty _POWERLINE_MODE variable')
		return None
	default = default or segment_info['environ'].get('_POWERLINE_DEFAULT_MODE')
	if mode == default:
		return None
	try:
		return override[mode]
	except KeyError:
		return mode.upper()

STATE_SYMBOLS = {
	'fallback': '',
	'play': '>',
	'pause': '~',
	'stop': 'X',
}

def itunes(pl, format='{state_symbol} {artist} - {title} ({total})', state_symbols=STATE_SYMBOLS, **kwargs):
	stats = {
			'state': 'fallback',
			'album': None,
			'artist': None,
			'title': None,
			'elapsed': None,
			'total': None,
			}
	func_stats = _get_itunes_status(pl)
	if not func_stats:
		return None
	pl.warn(func_stats)
	stats.update(func_stats)
	stats['state_symbol'] = state_symbols.get(stats['state']).encode('utf-8')
	return [{
		'contents': format.format(**stats),
		'highlight_group': ['now_playing', 'player_' + (stats['state'] or 'fallback'), 'player'],
		}]

def _get_itunes_status(pl):
	status_delimiter = '-~`/='
	ascript = '''
		tell application "System Events"
			set itunes_active to the count(every process whose name is "iTunes")
			if itunes_active is 0 then
				return
			end if
		end tell

		tell application "iTunes"
			set player_state to player state
			set track_name to name of current track
			set artist_name to artist of current track
			set album_name to album of current track
			set trim_length to 40
			set music_duration to the duration of the current track
			set music_elapsed to the player position
			return track_name & "{0}" & artist_name & "{0}" & album_name & "{0}" & music_elapsed & "{0}" & music_duration & "{0}" & player_state
		end tell
	'''.format(status_delimiter)
	now_playing = asrun(pl, ascript)
	if not now_playing:
		return
	now_playing = now_playing.split(status_delimiter)
	if len(now_playing) != 6:
		return
	state = _convert_state(now_playing[5])
	total = _convert_seconds(now_playing[4])
	elapsed = _convert_seconds(float(now_playing[3]) * float(now_playing[4]) / 100)
	return {
			'title': now_playing[0],
			'artist': now_playing[1],
			'album': now_playing[2],
			'elapsed': elapsed,
			'total': total,
			'state': state,
			}

def _convert_state(state):
	'''Guess player state'''
	state = state.lower()
	if 'play' in state:
		return 'play'
	if 'pause' in state:
		return 'pause'
	if 'stop' in state:
		return 'stop'
	return 'fallback'

def _convert_seconds(seconds):
	'''Convert seconds to minutes:seconds format'''
	return '{0:.0f}:{1:02.0f}'.format(*divmod(float(seconds), 60))
