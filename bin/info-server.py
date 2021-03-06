#!/usr/bin/env python
# -*- encoding=utf-8 -*-

from __future__ import absolute_import

import cgi
from ctypes.wintypes import BYTE, LONG
import ctypes
import json
import socket
import time
import http.server

def get_local_ip():
    for ip in socket.gethostbyname_ex(socket.gethostname())[2]:
        if not ip.startswith('127.'): return ip

HOST_NAME = get_local_ip()
#HOST_NAME = '127.0.0.1'
PORT_NUMBER = 18080

def get_battery():
    class SystemPowerStatus(ctypes.Structure):
        _fields_ = [
                ('ACLineStatus', BYTE),
                ('BatteryFlag', BYTE),
                ('BatteryLifePercent', BYTE),
                ('Reserved1', BYTE),
                ('BatteryLifeTime', LONG),
                ('BatteryFullLifeTime', LONG),
                ]

    sps = SystemPowerStatus()
    ctypes.windll.kernel32.GetSystemPowerStatus(ctypes.byref(sps))

    if   not sps.ACLineStatus:  status = 'offline'
    elif sps.ACLineStatus & 1:  status = 'online'
    elif sps.ACLineStatus & 2:  status = 'unknown'
    elif sps.BatteryFlag & 128: status = 'no battery'
    elif sps.BatteryFlag & 256: status = 'battery error'
    else:                       status = 'error'

    if   sps.BatteryFlag & 1:   condition = 'high'
    elif sps.BatteryFlag & 2:   condition = 'low'
    elif sps.BatteryFlag & 4:   condition = 'critical'
    else:                       condition = 'error'

    charging = True if sps.BatteryFlag & 8 else False
    remain_seconds = sps.BatteryFullLifeTime \
            if charging else sps.BatteryLifeTime
    remain = '{0:.0f}:{1:02.0f}'.format(
            abs(remain_seconds / 3600), abs(remain_seconds / 60 % 60))

    battery = {
            'status': status,
            'condition': condition,
            'charging': charging,
            'percent': sps.BatteryLifePercent,
            'remain': remain,
            }

    return battery

last_message = {
        'body': '',
        }

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        res = json.dumps({
            'battery': get_battery(),
            'message': last_message,
            })
        self.wfile.write(res.encode('utf-8'))

    def do_POST(self):
        form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={
                    'REQUEST_METHOD': 'POST',
                    'CONTENT_TYPE': self.headers['Content-Type'],
                    })

        message = form.getvalue('message')

        if not message:
            self.send_response(400)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write('400 Bad Request')

        else:
            global last_message
            last_message = {
                    'body': message,
                    'timestamp': time.time(),
                    }

            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write('200 OK')

if __name__ == '__main__':
    server_class = http.server.HTTPServer
    httpd = server_class((HOST_NAME, PORT_NUMBER), MyHandler)
    print('{0} Server Starts - {1}:{2}'.
            format(time.asctime(), HOST_NAME, PORT_NUMBER))
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print('{0} Server Stops - {1}:{2}'.
            format(time.asctime(), HOST_NAME, PORT_NUMBER))

