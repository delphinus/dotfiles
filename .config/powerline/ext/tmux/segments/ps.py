# -*- coding: utf-8 -*-
# vim:se fenc=utf-8 noet:

from __future__ import (unicode_literals, division, absolute_import, print_function)

import commands
import multiprocessing
import psutil
import re
import socket

from powerline.lib import add_divider_highlight_group
from powerline.lib.threaded import ThreadedSegment
from powerline.segments import with_docstring

class UsedMemoryPercentSegment(ThreadedSegment):
	interval = 1

	def active_memory_percent(self):
		try:
			return psutil.virtual_memory().percent
		except:
			return psutil.phymem_usage().percent

	def update(self, old_used_memory):
		return self.active_memory_percent()

	def run(self):
		while not self.shutdown_event.is_set():
			try:
				self.update_value = self.active_memory_percent()
			except Exception as e:
				self.exception('Exception whilte calculating used_memory_percent: {0}', str(e))

	def render(self, used_memory_percent, format='{0:.0f}%', **kwargs):
		if not used_memory_percent:
			return None
		return [{
			'contents': format.format(used_memory_percent),
			'gradient_level': used_memory_percent,
			'highlight_groups': ['used_memory_percent_gradient', 'used_memory_percent']
			}]

#used_memory_percent = with_docstring(UsedMemoryPercentSegment(),
#'''Return used memory as a percentage.
#
#Requires the ``psutil`` module.
#
#:param str format:
#	Output format. Accepts measured used memory as the first argument.
#
#Highlight groups used: ``used_memory_percent_gradient`` (gradient) or ``used_memory_percent``.
#''')

def used_memory_percent(pl, format='{0:.0f}%'):
	try:
		memory = psutil.virtual_memory().percent
	except:
		memory = psutil.phymem_usage().percent

	return [{
		'contents': format.format(memory),
		'gradient_level': memory,
		'highlight_groups': ['used_memory_percent_gradient', 'used_memory_percent'],
		}]

def used_memory(pl, steps=5, circle_glyph='●', memory_glyph='🔲'):
	try:
		memory = psutil.virtual_memory().percent
	except:
		memory = psutil.phymem_usage().percent

	ret = []
	denom = int(steps)
	numer = int(denom * memory / 100)
	ret.append({
		'contents': memory_glyph + ' ',
		'draw_soft_divider': False,
		'divider_highlight_group': 'background:divider',
		'highlight_groups': ['used_memory'],
		'gradient_level': 99,
		})
	ret.append({
		'contents': circle_glyph * numer,
		'draw_soft_divider': False,
		'highlight_groups': ['used_memory'],
		'gradient_level': 99,
		})
	ret.append({
		'contents': circle_glyph * (denom - numer),
		'draw_soft_divider': False,
		'highlight_groups': ['used_memory'],
		'gradient_level': 1,
		})

	return ret

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
		'highlight_groups': ['battery_percent_gradient', 'battery_percent'],
		'draw_divider': True,
		'divider_highlight_group': 'background:divider',
		'gradient_level': 100 - battery['percent'],
		}]

@add_divider_highlight_group('background:divider')
def internal_ip(pl):
	for ip in socket.gethostbyname_ex(socket.gethostname())[2]:
		if not ip.startswith('127.'):
			return ip

class CPULoad(ThreadedSegment):
	interval = 1
	cpu_num = multiprocessing.cpu_count()

	def update(self, old_cpu):
		return psutil.cpu_percent(interval=None)

	def run(self):
		while not self.shutdown_event.is_set():
			try:
				self.update_value = psutil.cpu_percent(interval=self.interval)
			except Exception as e:
				self.exception('Exception while calculating cpu_percent: {0}', str(e))

	def render(self, cpu_percent, steps=5, circle_glyph='●', cpu_glyph='💻', **kwargs):
		if not cpu_percent: return None

		ret = []
		denom = int(steps)
		numer = int(denom * cpu_percent / 100)
		#numer = int(denom * cpu_percent / (100 * self.cpu_num))
		#self.warn('{0}, {1}, {2}'.format(denom, cpu_percent, numer))
		ret.append({
			'contents': cpu_glyph + ' ',
			'draw_soft_divider': False,
			'divider_highlight_group': 'background:divider',
			'highlight_group': ['cpu_load'],
			'gradient_level': 99,
			})
		ret.append({
			'contents': circle_glyph * numer,
			'draw_soft_divider': False,
			'divider_highlight_group': 'background:divider',
			'highlight_group': ['cpu_load'],
			'gradient_level': 99,
			})
		ret.append({
			'contents': circle_glyph * (denom - numer),
			'draw_soft_divider': False,
			'divider_highlight_group': 'background:divider',
			'highlight_group': ['cpu_load'],
			'gradient_level': 1,
			})

		return ret

cpu_load = with_docstring(CPULoad(), '')
