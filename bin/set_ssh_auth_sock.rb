#!/usr/bin/env ruby
if ! ENV['SSH_AUTH_SOCK'].is_a?(String) || ENV['SSH_AUTH_SOCK'].empty?
  warn "invalid \$SSH_AUTH_SOCK: '#{ENV['SSH_AUTH_SOCK']}'"
  exit false
end

ssh_auth_sock_path = "#{ENV['HOME']}/.ssh/auth_sock"

def available_as_sock?(file_path)
  test(?S, file_path) && test(?r, file_path)
end

if ENV['SSH_AUTH_SOCK'] == ssh_auth_sock_path
  if available_as_sock? ssh_auth_sock_path
    warn "'#{ssh_auth_sock_path}' is sock"
    exit true
  end
  sock_file = Dir.glob('/tmp/ssh*/*')[0]
else
  sock_file = ENV['SSH_AUTH_SOCK']
end

if available_as_sock? sock_file
  File.delete ssh_auth_sock_path if test ?l, ssh_auth_sock_path
  File.symlink sock_file, ssh_auth_sock_path
  warn "set symlink #{sock_file} => #{ssh_auth_sock_path}"
else
  warn "'#{sock_file}' is not sock"
end
