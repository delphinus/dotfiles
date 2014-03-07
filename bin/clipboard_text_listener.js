var ws = new ActiveXObject('WScript.Shell'),
    vbHide = 0,
    perl = 'C:\\strawberry\\perl\\bin\\perl.exe',
    script = '%HOME%\\git\\ClipboardTextListener\\clipboard_text_listener.pl',
    arg1 = '-key',
    arg2 = 'delphinus';

ws.Run([perl, script, arg1, arg2].join(' '), vbHide, true);
