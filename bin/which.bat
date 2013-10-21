@echo off
rem 引数が無いとき
if "%~1"=="" (
echo search command-path from PATH
echo by hishidama 2006-07-06
echo usage: %0 command
exit/b
)

setlocal

rem ファイルそのものが存在しているとき
if exist %~1 (
set f=%~f1
goto end
)

rem エイリアスの探索
for /f "delims== tokens=1,*" %%i in ('doskey /macros') do (
if "%%i"=="%~1" set f=%%j & goto end
)

rem 拡張子があるとき
if not "%~x1"=="" (
set f=%~f$PATH:1
goto end
)

rem 拡張子を付与してカレントディレクトリの探索
for %%e in (%PATHEXT%) do (
if exist %~1%%e call :full_path %~1%%e & goto end
)

rem 拡張子を付与して環境変数PATHの探索
for %%e in (%PATHEXT%) do (
call :search_path %~1%%e
if errorlevel 1 goto end
)
set f=
goto end

:full_path
set f=%~f1
exit/b

:search_path
set f=%~$PATH:1
if "%f%"=="" exit/b 0
exit/b 1

:end
echo %1=%f%
endlocal
