#!/usr/bin/env ruby
(0xe000 .. 0xefff).each do |code|
  printf '%04x ', code if code % 16 == 0
  print code.chr('utf-8') + '  '
  print ".\n" if code % 16 == 15
end
