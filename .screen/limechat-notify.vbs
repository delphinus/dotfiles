Option Explicit

Dim args, ws
Set args = WScript.Arguments
Set ws = WScript.CreateObject("WScript.Shell")
ws.Run "cmd /c %HOME%\git\dotfiles\.screen\limechat-notify.bat """ & args(0) & """", 0
