@echo off
doskey alias=doskey $*
doskey ls=ls -F --color=auto $*
doskey ll=ls -lF --color=auto $*
doskey la=ls -aF --color=auto $*
doskey l.=ls -dF --color=auto .* $*
