# -*- coding: utf-8 -*-
# vim:se fenc=utf-8 noet:

from __future__ import absolute_import

import commands
import psutil
import re

import logging
logging.basicConfig(filename='/tmp/powerline.log')

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
		discharging='', charged='', remain='remain {0}:{1}'):
	pmset_output = commands.getoutput('pmset -g ps')
	r = re.compile(r"Currently drawing from '(.*)'" + \
			r'.*-InternalBattery-\d+\s+(\d+)%;' + \
			r'\s+((?:dis)?charging|charged);' + \
			r'\s+(\d+):(\d+) remaining', re.S)
	m = r.search(pmset_output)

	if m == None:
		return

	remain = remain.format(m.group(4), m.group(5))

	if m.group(3) == 'charging'      : status = charging
	elif m.group(3) == 'discharging' : status = discharging
	elif m.group(3) == 'charged'     : status = ''; remain = charged

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
