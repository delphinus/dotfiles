#!/usr/bin/env ruby
{
  :'seti-ui' =>                (0xe5fa .. 0xe62b),
  devicons:                    (0xe700 .. 0xe7c5),
  :'powerline-1' =>            (0xe0a0 .. 0xe0a2),
  :'powerline-2' =>            (0xe0b0 .. 0xe0b3),
  :'powerline-extra-1' =>      (0xe0a3 .. 0xe0a3),
  :'powerline-extra-2' =>      (0xe0b4 .. 0xe0c8),
  :'powerline-extra-3' =>      (0xe0cc .. 0xe0d4),
  pomicons:                    (0xe000 .. 0xe00a),
  :'font-awesome' =>           (0xf000 .. 0xf2e0),
  :'font-awesome-extension' => (0xe200 .. 0xe2a9),
  :'font-linux' =>             (0xf300 .. 0xf315),
  :'power-symbols-1' =>        (0x23fb .. 0x23fe),
  :'power-symbols-2' =>        (0x2b58 .. 0x2b58),
  :'octicons-1' =>             (0xf400 .. 0xf4a7),
  :'octicons-2' =>             (0xf112 .. 0xf112),
  :'octicons-3' =>             (0xf67c .. 0xf67c),
  :'octicons-4' =>             (0x2665 .. 0x2665),
  :'octicons-5' =>             (0x26a1 .. 0x26a1),
  :'octicons-6' =>             (0xf27c .. 0xf27c),
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
