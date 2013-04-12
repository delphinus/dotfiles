# -*- coding: utf-8 -*-
# vim:se fenc=utf-8 noet:

from __future__ import absolute_import

import commands
import json
import psutil
import re

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

	pl.warn(raw_res)
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

def last_message(pl, format=u'{0}'):
	raw_res = urllib_read('http://127.0.0.1:18080')

	if not raw_res:
		pl.error('Failed to get response')
		return

	res = json.loads(raw_res)
	message = res['message']

	if not message: return

	return [{
		'contents': format.format(message),
		'highlight_group': ['last_message'],
		'draw_divider': True,
		'divider_highlight_group': 'background:divider',
		}]
