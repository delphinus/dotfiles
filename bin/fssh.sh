#!/bin/bash
# fssh execution script to set in iTerm2 profile
if [[ ! $PATH =~ /usr/local/bin ]]; then
  export PATH=/usr/local/bin:$PATH
fi
exec fssh "$@"
