#!/usr/bin/env ruby
open('/tmp/test.txt', 'w') do |f|
  f.print '       '
  (0 .. 15).each do |head|
    f.print ' %x ' % head
  end
  f.puts ';'

  (0xe000 .. 0xefff).each do |code|
    chr = code.chr Encoding::UTF_8
    case code % 16
    when 0
      f.print '0x%04x %s  ' % [code, chr]
    when 15
      f.puts "#{chr}  ;"
    else
      f.print "#{chr}  "
    end
  end
end
