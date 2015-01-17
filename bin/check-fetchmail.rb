#!/usr/bin/env ruby
require 'syslog'

PROCESS_SUCCESS           = 0
PROCESS_NO_ROOT_USER      = 1
PROCESS_FETCHMAIL_RESTART = 2

unless Process.uid == 0
  warn 'execute on ROOT user'
  exit PROCESS_NO_ROOT_USER
end

GREP      = '/bin/grep'
PGREP     = '/usr/bin/pgrep'
FETCHMAIL = '/usr/bin/fetchmail'
SERVICE   = '/sbin/service'
USERS     = Dir['/home/*/.fetchmailrc'].map do |rc|
  $1 if rc =~ %r[/home/([^/]*)/\.fetchmailrc]
end

process_exist = USERS.reject do |user|
  system "#{PGREP} -fl #{FETCHMAIL} | #{GREP} #{user} | #{GREP} -v grep"
end

if process_exist.empty?
  Syslog.open File.basename($0) do |syslog|
    syslog.log Syslog::LOG_INFO, 'process checked for user [ %s ]', USERS.join(', ')
  end
  exit PROCESS_SUCCESS if process_exist.empty?
end

system "#{SERVICE} fetchmail restart"

Syslog.open File.basename($0) do |syslog|
  syslog.log Syslog::LOG_WARNING, 'process restart'
end
exit PROCESS_FETCHMAIL_RESTART
