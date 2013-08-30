# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

from __future__ import absolute_import

from powerline.lib.threaded import KwThreadedSegment, with_docstring

from collections import namedtuple
import commands
import re

_BatteryPercentKey = namedtuple('Key', 'charging discharging charged remain')

class BatteryPercent(KwThreadedSegment):
	interval = 30

	def __init__(self):
		super(BatteryPercent, self).__init__()

	@staticmethod
	def key(charging='charging', discharging='',
			charged='', remain='remain {0}', **kwargs):
		return _BatteryPercentKey(charging, discharging, charged, remain)

	def compute_state(self, key):
		self.pl.warn('computing')
		pmset_output = commands.getoutput('pmset -g ps')
		r = re.compile(r"Currently drawing from '(.*)'"
				r'.*-InternalBattery-\d+\s+(\d+)%;'
				r'\s+((?:dis)?charging|charged);'
				r'\s+((\d+:\d+)? remaining|\(no estimate\))', re.S)
		m = r.search(pmset_output)

		if m == None: return

		if m.lastindex == 3 : remain = ''
		else                : remain = key.remain.format(m.group(5))

		if   m.group(3) == 'charging'    : status = key.charging
		elif m.group(3) == 'discharging' : status = key.discharging
		elif m.group(3) == 'charged'     : status = key.charged; remain = ''

		battery = {
				'percent': int(m.group(2)),
				'status': status,
				'remain': remain,
				}

		return battery

	def render_one(self, battery, format='{percent}%', **kwargs):
		return [{
			'contents': format.format(**battery),
			'highlight_group': ['battery_percent_gradient', 'battery_percent'],
			'draw_divider': True,
			'divider_highlight_group': 'background:divider',
			'gradient_level': 100 - battery['percent'],
			}]

battery_percent = with_docstring(BatteryPercent(), '')
