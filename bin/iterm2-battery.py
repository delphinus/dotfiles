#!/usr/bin/env python3

import asyncio
from iterm2 import StatusBarComponent, Registration, run_forever
from math import floor
import re
from subprocess import CalledProcessError, check_output
from datetime import datetime

chars = [
    '▏',
    '▎',
    '▍',
    '▌',
    '▋',
    '▊',
    '▉',
    '█']
thunder = 'ϟ'
width = 5

class Timer:
    interval_seconds = 30
    updated = 0
    last = ''

    def can_run(self):
        print('checking')
        now = datetime.now().timestamp()
        return now - self.updated >= self.interval_seconds

    def last_text(self):
        return self.last

    def interval(self):
        return self.interval_seconds

    def update(self, text):
        print('updated')
        self.updated = datetime.now().timestamp()
        self.last = text


async def main(connection):
    timer = Timer()
    component = StatusBarComponent(
        'Battery',
        'Show battery remaining',
        'Show remaining time for battery',
        [],
        '|███▎  | 66% 2:34',
        timer.interval())

    async def coro(knobs):
        if not timer.can_run():
            return timer.last_text()
        try:
            out = check_output(
                args=['/usr/bin/pmset', '-g', 'batt']).decode('utf-8')
        except CalledProcessError as err:
            return '`pmset` cannot be executed'
        try:
            status = re.match(r'.*; (.*);', out, flags=re.S)[1]
            percent = int(re.match(r'.*?(\d+)%', out, flags=re.S)[1])
        except:
            return '🔌'
        if status == 'charged':
            battery = width * chars[-1]
        elif status == 'charging':
            mid = floor(width / 2)
            battery = mid * ' ' + thunder + (width - mid - 1) * ' '
        elif status == 'discharging':
            unit = len(chars)
            total_char_len = len(chars) * width
            char_len = floor(total_char_len * percent / 100)
            full_len = floor(char_len / unit)
            remained = char_len % unit
            space_len = width - full_len - (0 if remained == 0 else 1)
            battery = chars[-1] * full_len
            if remained != 0:
                battery += chars[remained - 1]
            battery += ' ' * space_len
        else:
            battery = ' ' * width
        matched = re.match(r'.*?(\d+:\d+)', out, flags=re.S)
        elapsed = matched[1] if matched and matched[1] != '0:00' else ''
        last_status = '{0} |{1}| {2:d}% {3}'.format(
            '🔋', battery, percent, elapsed)
        timer.update(last_status)
        return last_status


    await Registration.async_register_status_bar_component(
        connection, component, coro, defaults={})


run_forever(main)
