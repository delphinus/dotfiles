# -*- coding: utf-8 -*-
# vim:se fenc=utf-8 noet:

from __future__ import absolute_import

import commands
import json
import math
import psutil
import os
import re
import time

from powerline.lib.url import urllib_read

def cpu_load_percent_gradient(pl, format='{0:.0f}%', measure_interval=.5):
	cpu_percent = psutil.cpu_percent(interval=measure_interval)
	return [{
		'contents': format.format(cpu_percent),
		'highlight_group': ['cpu_load_percent_gradient', 'cpu_load_percent'],
		'draw_divider': True,
		'divider_highlight_group': 'background:divider',
		'gradient_level': cpu_percent,
		}]

def used_memory_percent_gradient(pl, format='{0:.0f}%'):
	memory_percent = float(psutil.used_phymem()) * 100 / psutil.TOTAL_PHYMEM
	return [{
		'contents': format.format(memory_percent),
		'highlight_group': ['used_memory_percent_gradient', 'used_memory_percent'],
		'draw_divider': True,
		'divider_highlight_group': 'background:divider',
		'gradient_level': memory_percent,
		}]

def battery_percent_gradient(pl, format='{percent}%', charging='charging',
		discharging='', charged='', remain='remain {0}'):
	pmset_output = commands.getoutput('pmset -g ps')
	r = re.compile(r"Currently drawing from '(.*)'" + \
			r'.*-InternalBattery-\d+\s+(\d+)%;' + \
			r'\s+((?:dis)?charging|charged);' + \
			r'\s+((\d+:\d+)? remaining|\(no estimate\))', re.S)
	m = r.search(pmset_output)

	if m == None:
		return

	if m.lastindex == 3 : remain = ''
	else                : remain = remain.format(m.group(5))

	if m.group(3) == 'charging'      : status = charging
	elif m.group(3) == 'discharging' : status = discharging
	elif m.group(3) == 'charged'     : status = charged; remain = ''

	battery = {
			'percent': int(m.group(2)),
			'status': status,
			'remain': remain,
			}

	return [{
		'contents': format.format(**battery),
		'highlight_group': ['battery_percent_gradient', 'battery_percent'],
		'draw_divider': True,
		'divider_highlight_group': 'background:divider',
		'gradient_level': 100 - battery['percent'],
		}]

def host_battery_percent_gradient(pl, format='{percent}%', charged='charged',
		charging='charging', discharging='', remain='remain {0}'):
	raw_res = urllib_read('http://127.0.0.1:18080')

	if not raw_res:
		pl.error('Failed to get response')
		return

	res = json.loads(raw_res)
	battery = res['battery']

	if battery['charging']:
		status = charged if battery['percent'] == 100 else charging
		remain = ''
	elif not battery['charging']:
		status = discharging
		remain = remain.format(battery['remain'])

	battery = {
			'percent': battery['percent'],
			'status': status,
			'remain': remain,
			}

	return [{
		'contents': format.format(**battery),
		'highlight_group': ['battery_percent_gradient', 'battery_percent'],
		'draw_divider': True,
		'divider_highlight_group': 'background:divider',
		'gradient_level': 100 - battery['percent'],
		}]

def last_message(pl, format=u'{now} {body}', max_length=30,
		time_format='%Y-%m-%d %H:%M:%S',
		match_string='',
		match_string_file='~/.message-match'):
	raw_res = urllib_read('http://127.0.0.1:18080')

	if not raw_res:
		pl.error('Failed to get response')
		return

	res = json.loads(raw_res)
	message = res['message']
	body = message['body']

	filename = '/tmp/last-message-history.log'
	last_message = (_get_last_line('/tmp/last-message-history.log', 1))[0]

	s = re.split(r',', last_message.decode('utf-8'))
	last_time = s[0] if len(s) else None
	last_body = ''.join(s[1:]).rstrip() if len(s) else None

	now = time.strftime(time_format)

	if body != last_body:
		with open(filename, 'a') as f:
			f.write('{0},{1}\n'.format(now, body.encode('utf-8')))

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
		gradient_level = 100 if r.search(body) else 0

	param = {
			'now': last_time if last_time else now,
			'body': body[:max_length],
			}

	return [{
		'contents': format.format(**param),
		'highlight_group': ['last_message_gradient', 'last_message'],
		'draw_divider': True,
		'divider_highlight_group': 'background:divider',
		'gradient_level': gradient_level,
		}]

def _get_last_line(filename, num):
	f = open(filename, 'r')
	filesize = os.path.getsize(filename)
	bufsize = 512
	pos = int(math.ceil(float(filesize) / bufsize))

	buf_tmp = ''
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
			tail[1:1] = lines

		if len(tail) > num:
			break
		else:
			pos -= 1

	if len(tail) > num:
		tail = tail[-num:]

	return tail
