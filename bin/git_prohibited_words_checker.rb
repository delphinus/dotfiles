#!/usr/bin/env ruby
require 'mail'
require 'optparse'
require 'pathname'
require 'socket'
require 'syslog'

DEFAULT_DIR           = Pathname('~/git/dotfiles').expand_path
PROHIBITED_WORDS_FILE = Pathname('~/.git_prohibited_words').expand_path
MAIL_PASSWORD_FILE    = Pathname('~/.git_prohibited_words_checker_password').expand_path

class String
  def red; STDOUT.isatty ? "\033[31m#{self}\033[0m" : self end
end

class DirectoryNotFoundError < StandardError
  def to_s; 'specified directory is not found' end
end

class ProhibitedWordsNotFoundError < StandardError
  def to_s; 'specified prohibited words file is not found' end
end

params = ARGV.getopts 'd:p:v'
begin
  start_dir = if params['d']
                Pathname(params['d']).expand_path
              else
                DEFAULT_DIR
              end
  raise DirectoryNotFoundError unless Dir.exists? start_dir

  prohibited_words_file = if params['p']
                            Pathname(params['p']).expand_path
                          else
                            PROHIBITED_WORDS_FILE
                          end
  raise ProhibitedWordsNotFoundError unless File.readable? prohibited_words_file
rescue => e
  warn e.to_s.red
  exit 1
end

prohibited_words_pre = Regexp.new IO.readlines(prohibited_words_file).map(&:chomp).join '|'

ignore_names_re = %r[
  \Abin/local_perl\.sh\z |
  \A\.git/ |
  \A\.screen/(?:cpu|memory)\z |
  \A\.?vim/view/ |
  \A\.?vim/dict/ |
  \A\.zsh/zsh-notify/ |
  \Asubmodules/ |
  \.pyc$ |
  \.sqlite$ |
  \.exe$ |
  \.rpm$ |
  \.tmux/resurrect |
  \.tmux/plugins |
  \.zprezto/modules/completion/external/src
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
  ary << file if IO.read(file).scrub =~ prohibited_words_pre
end

mail_body_header = sprintf 'dotfiles scan for prohibited words; scaned: %d file(s), skipped: %d file(s), found: %d file(s)', scan_count, skip_count, errors.size

puts(mail_body_header) if params['v']

Syslog.open File.basename($0) do |syslog|
  syslog.notice mail_body_header
end

exit if errors.count == 0

Syslog.open File.basename($0) do |syslog|
  syslog.warning "prohibited words found in #{errors.join(', ')}"
end

unless File.readable? MAIL_PASSWORD_FILE
  Syslog.open File.basename($0) do |syslog|
    syslog.warning "#{MAIL_PASSWORD_FILE} is not readble"
  end
  exit 1
end

mail_body = mail_body_header + "\n\n"
errors.each do |e|
  mail_body += "  - #{e}"
end

mail = Mail.new do
  from    'root@remora.cx'
  to      'delphinus@remora.cx'
  subject '[prohibited words checker] %s %s report' % [Socket.gethostname, Date.today.strftime('%Y/%m/%d')]
  body    mail_body
end

mail.delivery_method :smtp, {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'smtp.gmail.com',
  user_name: 'me@delphinus.dev',
  password: IO.read(MAIL_PASSWORD_FILE).chomp,
  authentication: :plain,
}

mail.deliver
