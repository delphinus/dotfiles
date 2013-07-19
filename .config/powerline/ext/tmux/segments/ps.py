# -*- coding: utf-8 -*-
# vim:se fenc=utf-8 noet:

from __future__ import absolute_import

import commands
import psutil
import re
import socket

from powerline.lib import add_divider_highlight_group

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

@add_divider_highlight_group('background:divider')
def internal_ip(pl):
	for ip in socket.gethostbyname_ex(socket.gethostname())[2]:
		if not ip.startswith('127.'):
			return ip
