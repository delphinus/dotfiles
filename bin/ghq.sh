#!/bin/sh
if [ -n "$H" ]; then
  HOME=$H ghq $@
else
  ghq $@
fi
