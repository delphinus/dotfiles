#!/usr/bin/env ruby
require 'pathname'
prefix = Pathname `brew --prefix`.chomp
puts(`brew ls --versions`.split("\n").each_with_object([]) do |str, ary|
  brew, *versions = str.split /\s+/
  versions.each do |v|
    ary << prefix + 'Celler' + brew + v
  end
end.join "\n")
