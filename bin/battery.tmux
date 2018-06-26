#!/bin/bash
HAS_BATTERY_FLAG_FILE=/tmp/__battery_tmux_system_has_battery
HAS_NO_BATTERY_FLAG_FILE=/tmp/__battery_tmux_system_has_no_battery
if [[ -f $HAS_BATTERY_FLAG_FILE ]]; then
  echo -n "$(battery -t -e)" ' '
elif [[ -f $HAS_NO_BATTERY_FLAG_FILE ]]; then
  echo -n ""
elif command -v battery > /dev/null 2>&1 && battery --has; then
  touch $HAS_BATTERY_FLAG_FILE
  echo -n "$(battery -t -e)" ' '
else
  touch $HAS_NO_BATTERY_FLAG_FILE
fi
exit 0
