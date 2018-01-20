#!/usr/bin/env ruby

require 'logger'
require 'optparse'
require 'ostruct'
require 'open3'

MODES = %i,set info create delete ls,
DEFAULT = {
  verbose:     false,
  host:        'remora.cx',
  user:        'git',
  description: '',
  mode:        :info,
  options:     '-l',
}

class MyOptions
  def self.parse!(argv)
    options = OpenStruct.new(DEFAULT)
    OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename($0)} [options] repository_name"

      opts.on '-v', '--[no-]verbose',
          "Run verbosely (default: #{options.verbose})" do |v|
        options.verbose = v
      end

      opts.on '-o HOST', '--host', "git host (default: #{options.host})" do |v|
        options.host = v
      end

      opts.on '-u USER', '--user', "git user (default: #{options.user})" do |v|
        options.user = v
      end

      opts.on '-d DESCRIPTION', '--description',
          "git description (default: '#{options.description}')"  do |v|
        options[:description] = v
      end

      opts.on '-m MODE', '--mode',
          "Select mode (#{MODES.join(',')}) (default: #{options.mode})" do |v|
        options.mode = :"#{v}"
      end

      opts.on '-p OPTIONS', '--options',
          "ls options (default: '#{options.options}')" do |v|
        options[:options] = v
      end

      opts.on_tail '-h', '--help', 'Show this message' do
        puts opts
        exit
      end
    end.parse!(argv)
    options
  end
end

class Repository
  attr_reader 'data'

  def initialize(name, options)
    @options   = options
    @log       = Logger.new STDERR
    @log.level = @options.verbose ? Logger::INFO : Logger::WARN
    @name      = name
    @home      = '$HOME'
    @path      = "#@home/#@name"
    @data      = OpenStruct.new get_data
  end

  def get_data
    @log.info 'checking description...'
    description, exist = nil, nil
    ssh_capture "cat #@path/description" do |out, err, exit_status|
      description = out.to_s.chomp!
      exist = exit_status.success?
      if @options.mode == :create
        abort 'repository exists already' if exist
      elsif @options.mode != :ls
        abort 'repository not found' unless exist
      end
    end
    {name: @name, descripton: description, exist: exist}
  end

  def ls
    @log.info "ls #@path..."
    ssh_capture "ls #{@options.options} #@path" do |out, err, exit_status|
      if exit_status.success?
        out
      else
        abort "ls failed: #{err}"
      end
    end
  end

  def set
    abort 'specify description' if @options.description.empty?
    print <<-EOL
repository_name: #{@name}
old description: '#{@data.description}'
new description: '#{@options.description}'
    EOL
    command = "echo '%s' > %s/description" % [@options.description, @path]
    ssh_capture command do |out, err, exit_status|
      abort "writing description failed: #{err}" unless exit_status.success?
    end
    'successfully set description'
  end

  def create
    command = ('mkdir -p %s && ' +
              'cd %s && ' +
              'git init --bare && ' +
              'echo "%s" > description') % [@path, @path, @options.description]
    @log.info 'repository creating...'
    ssh_capture command do |out, err, exit_status|
      abort "creating repository failed: #{err}" unless exit_status.success?
    end
    'successfully created'
  end

  def delete
    parent_dir = File.dirname @path
    basename = File.basename @path
    backup_filename = '%s-%s.tar.bz2' %
      [basename, Time.now.strftime('%Y%m%d%H%M%S')]
    command = ('cd %s && ' +
              'tar jcf %s %s/ && ' +
              'rm -r %s') % [parent_dir, backup_filename, basename, basename]
    @log.info 'repository deleting...'
    ssh_capture command do |out, err, exit_status|
      abort "deleting repository failed: #{err}" unless exit_status.success?
    end
    'successfully deleted'
  end

  def ssh_capture(cmd)
    command = "ssh %s@%s '%s'" % [@options.user, @options.host, cmd]
    @log.info 'ssh_capture: ' + command
    results = capture command
    yield results if block_given?
    results
  end

  def capture(cmd)
    out, err, exit_status = nil, nil, nil
    Open3.popen3 cmd do |stdin, stdout, stderr, wait_thr|
      exit_status = wait_thr.value
      out = stdout.readlines(nil)[0]
      err = stderr.readlines(nil)[0]
    end
    @log.info({out: out, err: err, exit_status: exit_status})
    return out, err, exit_status
  end
end

def main
  options = MyOptions.parse!(ARGV)
  name = ARGV.shift
  abort 'please specify a repository name' unless name
  repository = Repository.new(name, options)

  case options.mode
  when :info
    puts repository.data
  when :set
    puts repository.set
  when :create
    puts repository.create
  when :delete
    puts repository.delete
  when :ls
    puts repository.ls
  else
    abort "invalid mode: #{options.mode}"
  end
end

main if __FILE__ == $0
