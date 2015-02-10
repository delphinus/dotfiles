#!/usr/bin/env ruby
require 'optparse'
params = ARGV.getopts 'r:e:'
re_to_check = if params['e']
                Regexp.new '\.(?:' + params['e'].split(/\s*,\s*/).join('|') + ')\z'
              elsif params['r']
                Regexp.new params['r']
              else
                %r[\.(?:rb|pl|html|js|css|yml|yaml|txt|md)\z]
              end

error_filenames = `git diff --cached --name-only`.split("\n").select do |path|
  next unless File.file?(path) && path =~ re_to_check
  whole_script = IO.read(path)
  true if whole_script =~ /^ *\t/ && whole_script =~ /^\t* /
end

if error_filenames.count > 0
  warn "\033[31mfiles below has mixed indents.\033[0m"
  error_filenames.each { |n| warn "\033[31m  - #{n}\033[0m" }
  exit 1
else
  exit 0
end
