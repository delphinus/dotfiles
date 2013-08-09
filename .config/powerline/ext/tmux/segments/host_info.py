# vim:fileencoding=utf-8:noet

from __future__ import absolute_import

from powerline.lib.threaded import KwThreadedSegment, with_docstring
from powerline.lib.url import urllib_read
from collections import namedtuple
import json
import math
import os
import re
import time

_HostBatteryPercentKey = namedtuple('Key',
	'charged charging discharging remain')

class HostBatteryPercent(KwThreadedSegment):
	interval = 30

	@staticmethod
	def key(charged='charged', charging='charging', discharging='',
			remain='remain{0}', **kwargs):
		return _HostBatteryPercentKey(charged, charging, discharging, remain)

	def compute_state(self, key):
		raw_res = urllib_read('http://127.0.0.1:18080')

		if not raw_res:
			self.pl.error('Failed to get response')
			return

		res = json.loads(raw_res)
		data = res['battery']

		if data['charging']:
			status = key.charging
			remain = ''
		elif not data['charging']:
			if data['percent'] == 100:
				status = key.charged
				remain = ''
			else:
				status = key.discharging
				remain = key.remain.format(data['remain'])

		return {
				'percent': data['percent'],
				'status': status,
				'remain': remain,
				}

	@staticmethod
	def render_one(battery, format='{percent}%', **kwargs):
		if not battery:
			return None
		else:
			return [{
				'contents': format.format(**battery),
				'highlight_group':
					['battery_percent_gradient', 'battery_percent'],
				'draw_divider': True,
				'divider_highlight_group': 'background:divider',
				'gradient_level': 100 - battery['percent'],
				}]

host_battery_percent = with_docstring(HostBatteryPercent(), '')

_LastMessageKey = namedtuple('Key', 'time_format max_length')

class LastMessage(KwThreadedSegment):
	interval = 3

	@staticmethod
	def key(time_format='%Y-%m-%d %H:%M%S', max_length=30, **kwargs):
		return _LastMessageKey(time_format, max_length)

	def compute_state(self, key):
		raw_res = urllib_read('http://127.0.0.1:18080')

		if not raw_res:
			self.pl.error('Failed to response')
			return

		res = json.loads(raw_res)
		message = res['message']
		body = message['body']

		filename = '/tmp/last-message-history.log'
		last_message = (self.get_last_line(filename, 1))[0]

		s = re.split(r',', last_message.decode('utf-8'))
		last_time = s[0] if len(s) else None
		last_body = ''.join(s[1:]).rstrip() if len(s) else None

		now = time.strftime(key.time_format)

		if body != last_body:
			with open(filename, 'a') as f:
				f.write('{0},{1}\n'.format(now, body.encode('utf-8')))

		return {
				'now': last_time if last_time else now,
				'body': body[:key.max_length],
				}

	@staticmethod
	def render_one(last_message, format=u'{now} {body}',
			match_string='', match_string_file='~/.message-match', **kwargs):
		if len(match_string) == 0:
			try:
				tmp = []
				with open(os.path.expanduser(match_string_file)) as f:
					for line in f:
						tmp.append(line.rstrip())
				match_string = '|'.join(tmp)
			except IOError:
				pass

		if len(match_string) > 0:
			r = re.compile(match_string, re.I)
			gradient_level = 100 if r.search(last_message['body']) else 0

		return [{
			'contents': format.format(**last_message),
			'highlight_group': ['last_message_gradient', 'last_message'],
			'draw_divider': True,
			'divider_highlight_group': 'background:divider',
			'gradient_level': gradient_level,
			}]

	def get_last_line(self, filename, num):
		with open(filename, 'r') as f:
			filesize = os.path.getsize(filename)
			bufsize = 512
			pos =int(math.ceil(float(filesize) / bufsize))

			buf_tmp =''
			tail = []
			while pos:
				f.seek(bufsize * pos)
				buf = f.read(bufsize) + buf_tmp
				matches = re.findall(r'[^\x0D\x0A]*\x0D?\x0A?', buf)
				lines = []
				for i in xrange(len(matches)):
					if i == 0:
						buf_tmp = matches[i]
					else:
						lines.append(matches[i])

				if len(lines):
					lines.pop()
					tail[1:1] =lines

				if len(tail) > num:
					break
				else:
					pos -= 1

			if len(tail) > num:
				tail = tail[-num:]

		return tail

last_message = with_docstring(LastMessage(), '')
