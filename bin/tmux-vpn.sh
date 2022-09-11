#!/bin/bash
if ifconfig | grep ppp0 > /dev/null; then
  echo -n '#[fg=black,bg=green,bold]   VPN ON '
else
  echo -n '#[fg=red,bg=black]   VPN OFF '
fi
