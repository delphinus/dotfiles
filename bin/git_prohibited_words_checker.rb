#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mail'
require 'optparse'
require 'pathname'
require 'socket'
require 'syslog'

DEFAULT_DIR           = Pathname('~/git/dotfiles').expand_path
PROHIBITED_WORDS_FILE = Pathname('~/.git_prohibited_words').expand_path
MAIL_PASSWORD_FILE    =
  Pathname('~/.git_prohibited_words_checker_password').expand_path

class String
  def red
    STDOUT.isatty ? "\033[31m#{self}\033[0m" : self
  end
end

class DirectoryNotFoundError < StandardError
  def to_s
    'specified directory is not found'
  end
end

class ProhibitedWordsNotFoundError < StandardError
  def to_s
    'specified prohibited words file is not found'
  end
end

params = ARGV.getopts 'd:p:v'
begin
  start_dir = if params['d']
                Pathname(params['d']).expand_path
              else
                DEFAULT_DIR
              end
  raise DirectoryNotFoundError unless Dir.exist? start_dir

  prohibited_words_file = if params['p']
                            Pathname(params['p']).expand_path
                          else
                            PROHIBITED_WORDS_FILE
                          end
  raise ProhibitedWordsNotFoundError unless File.readable? prohibited_words_file
rescue StandardError => e
  warn e.to_s.red
  exit 1
end

prohibited_words_pre =
  Regexp.new IO.readlines(prohibited_words_file).map(&:chomp).join '|'

ignore_names_re = %r{
  \.exe$ |
  \.mypy_cache\b |
  \.pyc$ |
  \.rpm$ |
  \.sqlite$ |
  \.tmux/plugins |
  \.tmux/resurrect |
  \.zprezto/modules |
  \A\.?vim/dict/ |
  \A\.?vim/view/ |
  \A\.config/fish/config-local\.fish\z |
  \A\.config/nvim/\.netrwhist\z |
  \A\.git/ |
  \A\.screen/(?:cpu|memory)\z |
  \A\.zsh/zsh-notify/ |
  \Abin/local_perl\.sh\z |
  \Abin/macos-askpass\z |
  \Asubmodules/ |
  \bmigemo-dict\b |
  \bnode_modules\b
}x

scan_count = 0
skip_count = 0

files = Dir.glob(start_dir + '**/*', File::FNM_DOTMATCH).map do |path|
  Pathname(path).relative_path_from start_dir
end

scanned = files.select do |path|
  if File.file?(path) && path.to_s !~ ignore_names_re
    scan_count += 1
    true
  else
    skip_count += 1
    false
  end
end

errors = scanned.each_with_object [] do |file, ary|
  ary << file if IO.read(file).scrub =~ prohibited_words_pre
end

mail_body_header =
  format 'dotfiles scan for prohibited words; scanned: %<scanned>d file(s), skipped: %<skipped>d file(s), found: %<errors>d file(s)',
         scanned: scan_count,
         skipped: skip_count,
         errors: errors.size

puts(mail_body_header) if params['v']

Syslog.open File.basename($PROGRAM_NAME) do |syslog|
  syslog.notice mail_body_header
end

exit if errors.count.zero?

Syslog.open File.basename($PROGRAM_NAME) do |syslog|
  syslog.warning "prohibited words found in #{errors.join(', ')}"
end

unless File.readable? MAIL_PASSWORD_FILE
  Syslog.open File.basename($PROGRAM_NAME) do |syslog|
    syslog.warning "#{MAIL_PASSWORD_FILE} is not readble"
  end
  exit 1
end

mail_body = mail_body_header + "\n\n"
errors.each do |error|
  mail_body += "  - #{error}"
end

mail = Mail.new do
  from    'me@delphinus.dev'
  to      'me@delphinus.dev'
  subject format('[prohibited words checker] %<host>s %<ymd>s report',
                 host: Socket.gethostname, ymd: Date.today.strftime('%Y/%m/%d'))
  body    mail_body
end

mail.delivery_method :smtp,
                     address: 'smtp.gmail.com',
                     port: 587,
                     domain: 'smtp.gmail.com',
                     user_name: 'me@delphinus.dev',
                     password: IO.read(MAIL_PASSWORD_FILE).chomp,
                     authentication: :plain

mail.deliver
