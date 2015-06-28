#!/usr/bin/env ruby
amethyst = "#{ENV['HOME']}/.amethyst"
floating_setting_re = /^\s*"floating": [\s\S]*?\],(?=\n)/
old_setting = open(amethyst).read

raise 'floating_setting cannot be found' unless old_setting =~ floating_setting_re

floatings = $&.split("\n").each_with_object [] do |line, ary|
  ary << $& if line =~ /^\s*"[^"]*",?\s*$/
end

def setting_for word; %[    "#{word}",] end
added_setting = (ARGV[0] || `pbpaste`).split("\n").each_with_object [] do |line, ary|
  if line =~ /^BundleIdentifier:\s*(.*)$/ && ! floatings.include?(setting_for $1)
    ary << $1
    floatings << setting_for($1)
  end
end

open(amethyst, 'w').write old_setting.sub floating_setting_re, <<EOF.chomp
  "floating": [
#{floatings.sort.join("\n").sub /,\z/, ''}
  ],
EOF

puts <<EOF
added settings for:
#{added_setting.map{|s| "  #{s}"}.join "\n"}
EOF

__END__

特定のウィンドウを Amethyst による管理から除外するため、
~/.amethyst ファイルにエントリーを追加します。
追加する項目は第一引数か、ペーストボードから読み込みます。
Karabiner の Event Viewer からでウィンドウ情報をコピーしたあと、
このスクリプトを起動してください。
