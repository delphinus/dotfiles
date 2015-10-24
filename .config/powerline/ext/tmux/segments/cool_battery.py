# -*- coding: utf-8 -*-
# vim:se fenc=utf8 noet:

from __future__ import absolute_import

import re

from powerline.lib.shell import run_cmd

def battery(pl, format='{ac_state} {capacity:3.0%}', steps=5, gamify=False, full_heart='O', empty_heart='O', online='C', offline=' ', iconfy=False, icons='          ', icon_format='{0}  {1}'):
	try:
		capacity, ac_powered, estimated_time = _get_battery_status(pl)
	except NotImplementedError:
		pl.info('Unable to get battery status.')
		return None

	ret = []
	if gamify:
		denom = int(steps)
		numer = int(denom * capacity / 100)
		ret.append({
			'contents': online if ac_powered else offline,
			'draw_inner_divider': False,
			'highlight_groups': ['battery_online' if ac_powered else 'battery_offline', 'battery_ac_state', 'battery_gradient', 'battery'],
			'gradient_level': 0,
		})
		ret.append({
			'contents': full_heart * numer,
			'draw_inner_divider': False,
			'highlight_groups': ['battery_full', 'battery_gradient', 'battery'],
			# Using zero as “nothing to worry about”: it is least alert color.
			'gradient_level': 0,
		})
		ret.append({
			'contents': empty_heart * (denom - numer),
			'draw_inner_divider': False,
			'highlight_groups': ['battery_empty', 'battery_gradient', 'battery'],
			# Using a hundred as it is most alert color.
			'gradient_level': 100,
		})

	elif iconfy:
		icon_list = re.split(r'\s+', icons.strip())
		denom = len(icon_list) - 1
		icon = icon_list[denom * capacity / 100]
		ret.append({
			'contents': online if ac_powered else offline,
			'draw_inner_divider': False,
			'highlight_groups': ['battery_online' if ac_powered else 'battery_offline', 'battery_ac_state', 'battery_gradient', 'battery'],
			'gradient_level': 0,
		})
		ret.append({
			'contents': icon_format.format(icon, estimated_time),
			'draw_inner_divider': False,
			'highlight_groups': ['battery_gradient', 'battery'],
			# Using zero as “nothing to worry about”: it is least alert color.
			'gradient_level': 100 - capacity,
		})

	else:
		ret.append({
			'contents': format.format(ac_state=(online if ac_powered else offline), capacity=(capacity / 100.0)),
			'highlight_groups': ['battery_gradient', 'battery'],
			# Gradients are “least alert – most alert” by default, capacity has 
			# the opposite semantics.
			'gradient_level': 100 - capacity,
		})
	return ret

BATTERY_PERCENT_RE = re.compile(r'(\d+)%')
BATTERY_ESTIMATED_TIME_RE = re.compile(r'(\d+:\d+) remaining')

def _get_battery_status(pl):
	battery_summary = run_cmd(pl, ['pmset', '-g', 'batt'])
	battery_percent = BATTERY_PERCENT_RE.search(battery_summary).group(1)
	ac_charging = 'AC' in battery_summary
	estimated_time = BATTERY_ESTIMATED_TIME_RE.search(battery_summary).group(1) if '(no estimate)' not in battery_summary else '-:-'
	return int(battery_percent), ac_charging, estimated_time
