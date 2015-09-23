#!/usr/bin/env ruby
{
  pomicons:       (0xe000 .. 0xe00a),
  powerline:      (0xe0a0 .. 0xe0b3),
  original:       (0xe5fe .. 0xe62a),
  devicons:       (0xe700 .. 0xe7c5),
  'font-awesome': (0xf000 .. 0xf280),
  octicons:       (0xf400 .. 0xf4db),
}.each do |name, range|
  puts "# #{name}"
  puts ''
  printf '%04x %s', range.first.div(16) * 16, '   ' * (range.first % 16) if range.first % 16 != 0
  range.each do |code|
    printf '%04x ', code if code % 16 == 0
    print code.chr('utf-8') + '  '
    print ".\n" if code % 16 == 15 || range.last == code
  end
  puts ''
end
