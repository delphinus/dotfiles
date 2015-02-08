#!/usr/bin/env ruby
require 'mail'
require 'optparse'
require 'pathname'
require 'syslog'

class String
  def red; "\033[31m#{self}\033[0m" end
end

class DirectoryNotFoundError < StandardError
  def to_s; 'specified directory is not found' end
end

class ProhibitedWordsNotFoundError < StandardError
  def to_s; 'specified prohibited words file is not found' end
end

opt = OptionParser.new
begin
  params = opt.getopts ARGV, '', 'dir:', 'prohibited-words:'
  start_dir = if params['dir']
                Pathname(params['dir']).expand_path
              else
                Pathname('~/git/dotfiles').expand_path
              end
  raise DirectoryNotFoundError unless Dir.exists? start_dir

  prohibited_words_file = if params['prohibited-words']
                            Pathname(params['prohibited-words']).expand_path
                          else
                            Pathname('~/.git_prohibited_words').expand_path
                          end
  raise ProhibitedWordsNotFoundError unless File.readable? prohibited_words_file
rescue => e
  warn e.to_s.red
  exit 1
end

prohibited_words_pre = Regexp.new IO.readlines(prohibited_words_file).map(&:chomp).join '|'

ignore_names_re = %r[
  \A\.git/ |
  \A\.screen/(?:cpu|memory)\z |
  \A\.vim/bundle/ |
  \A\.zsh/zsh-notify/ |
  \Asubmodules/ |
  \.pyc$ |
  \.sqlite$ |
  \.exe$
]x

scan_count = 0
skip_count = 0

errors = Dir.glob(start_dir + '**/*', File::FNM_DOTMATCH).map do |path|
  Pathname(path).relative_path_from start_dir
end.select do |path|
  if File.file?(path) && path.to_s !~ ignore_names_re
    scan_count += 1
    true
  else
    skip_count += 1
    false
  end
end.each_with_object [] do |file, ary|
  ary << file if IO.read(file) =~ prohibited_words_pre
end

mail_body_header = sprintf 'dotfiles scan for prohibited words; scaned: %d file(s), skipped: %d file(s), found: %d file(s)', scan_count, skip_count, errors.size

Syslog.open File.basename($0) do |syslog|
  syslog.log Syslog::LOG_NOTICE, mail_body_header
  syslog.log Syslog::LOG_NOTICE, errors.join(', ')
end

exit if errors.count == 0

mail_body = mail_body_header + "\n\n"
errors.each do |e|
  mail_body += "  - #{e}"
end

mail = Mail.new do
  from    'root@remora.cx'
  to      'delphinus@remora.cx'
  subject '[prohibited words checker] %s report' % Date.today.strftime('%Y/%m/%d')
  body    mail_body
end

mail_password = IO.read(Pathname('~/.git_prohibited_words_checker_password').expand_path).chomp

mail.delivery_method :smtp, {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'smtp.gmail.com',
  user_name: 'delphinus@remora.cx',
  password: mail_password,
  authentication: :plain,
}

mail.deliver
