#!/bin/sh

awk '{print $1}' $HOME/.screen/.temp
$HOME/git/.screen/tempmonitor > .temp &

