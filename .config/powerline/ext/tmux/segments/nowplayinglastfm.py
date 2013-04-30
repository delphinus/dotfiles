# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

from __future__ import absolute_import

from powerline.lib.threaded import KwThreadedSegment, with_docstring
from powerline.lib.url import urllib_read, urllib_urlencode

from collections import namedtuple
import json
import re
import types

_NowPlayingKey = namedtuple(
	'Key', 'username api_key format shorten_artist shorten_title')

STATE_SYMBOLS = {
	'fallback': u'♫',
	'play': u'▶',
	'pause': u'▮▮',
	'stop': u'■',
	}

class NowPlayingLastFM(KwThreadedSegment):
	interval = 30

	@staticmethod
	def key(username, api_key, format=u'{state_symbol} {artist} - {title}',
			shorten_artist=False, shorten_title=False, **kwargs):
		return _NowPlayingKey(
				username, api_key, format, shorten_artist, shorten_title)

	def compute_state(self, key):
		if not key.username or not key.api_key:
			self.warn('Username and api_key are not configured')
			return None
		data = self.player(key)
		stats = {
				'state': None,
				'state_symbol': STATE_SYMBOLS['fallback'],
				'album': None,
				'artist': None,
				'title': None,
				'elapsed': None,
				'total': None,
				}
		stats.update(data)
		string = key.format.format(**stats)
		return string

	@staticmethod
	def render_one(string, **kwargs):
		return [{
			'contents': string,
			'highlight_group': ['now_playing'],
			'divider_highlight_group': 'background:divider',
			}]

	def player(self, key):
		query_data = {
				'method': 'user.getrecenttracks',
				'format': 'json',
				'user': key.username,
				'api_key': key.api_key,
				'nowplaying': 'true',
				}
		url = 'http://ws.audioscrobbler.com/2.0/?' + \
				urllib_urlencode(query_data)

		raw_response = urllib_read(url)
		if not raw_response:
			self.error('Failed to get response')
			return
		response = json.loads(raw_response)
		track_info = response['recenttracks']['track']
		track_info_type = type(track_info)
		if track_info_type == types.ListType:
			track = track_info[0]
			status = 'play'
		elif track_info_type == types.DictType:
			track = track_info[1]
		else:
			self.error('Invalid response')
			status = 'fallback'
			return

		artist = track['artist']['#text']
		if self.shorten_artist:
			artist = self.shorten_artist(artist)
		title = track['name']
		if self.shorten_title:
			title = self.shorten_title(title)

		return {
				'artist': artist,
				'title': title,
				'playing': status,
				}

	def shorten_artist(self, artist):
		r = re.compile(r'''
			(.+?)
			\s*
			(?:
				feat(?:uring)?\.?
				|
				Ft\.
				|
				pres(?:sents)?\.?
			)\b
			''', re.I | re.X)
		m = r.match(artist)
		if m:
			artist = m.group(1)
		return artist

	def shorten_title(self, title):
		m = re.match(r'(.+?)\s*\(.*\)', title)
		if m:
			title = m.group(1)
		return title

now_playing = with_docstring(NowPlayingLastFM(), '')
