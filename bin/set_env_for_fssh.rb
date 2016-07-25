#!/usr/bin/env ruby
tmux_fssh_port = `tmux showenv LC_FSSH_PORT 2> /dev/null` =~ /(?<==).*/ && $&
unless tmux_fssh_port == ENV['LC_FSSH_PORT']
  `env | grep LC_FSSH_`.scan /^([^=]+)=(.*)$/ do |name, value|
    system %Q[tmux setenv "#{name}" "#{value}"]
  end
end
