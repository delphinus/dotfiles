var ws = new ActiveXObject('WScript.Shell'),
    vbHide = 0,
    python = 'C:\\Python27\\python.exe',
    script = '%HOME%\\git\\dotfiles\\bin\\info-server.py';

ws.Run([python, script].join(' '), vbHide, true);
