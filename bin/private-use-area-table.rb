#!/usr/bin/env ruby
open('/tmp/test.txt', 'w') do |f|
  (0x1f300 .. 0x1f7ff).each do |code|
    if code % 0x100 == 0
      f.puts ''
      f.print '        '
      (0 .. 15).each do |head|
        f.print ' %x ' % head
      end
      f.puts ';'
    end

    chr = code.chr Encoding::UTF_8
    case code % 16
    when 0
      f.print '0x%05x %s ' % [code, chr]
    when 15
      f.puts "#{chr} ;"
    else
      f.print "#{chr} "
    end
  end
end
