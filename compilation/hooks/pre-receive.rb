#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'open4'
require 'utils'

ext_puts "10xLabs receiving push"

data = process_push_data

begin
  ext_puts "Starting compilation service..."

  # retrieve lab token
  res = get_lab_token(data[:repo])
  lab_token = res[:lab_token]
  lab_name = res[:lab_name]

  # build git repository URL
  config = File.join(ENV['HOME'], '.10xlab-repo')
  if File.exist? config
    repo_prefix = IO.read(config).strip
  else
    io = IO.popen('hostname')
    host_raw = io.readlines.first.strip

    repo_prefix = "#{ENV['USER']}@#{host_raw.first}"
  end

  repo = "#{repo_prefix}/#{data[:repo]}"

  # TODO use absolute path (need to set location)
  script_file = File.join(ENV['HOME'], 'compilation/hooks/10xlabs-compile.sh')
  command = [script_file, repo, lab_name, lab_token, data[:new_rev], data[:ref_name]]

  error = nil

  stat = Open4.popen4(command.join(' ')) do |pid, stdin, stdout, stderr|
    while line = stdout.gets
      ext_puts_x line
    end

    error = stderr.read.strip
  end

  if stat.exited?
    if stat.exitstatus > 0
      error_message = error.empty? ? (output.delete_if {|i| i.strip.empty?}).first : error 

      raise "Compilation failed (#{stat.exitstatus}): #{error_message}"
    end
  elsif stat.signaled?
    raise "Compilated terminated - signal #{stat.termsig}"
  elsif stat.stopped?
    raise "Compilated stopped - signal #{stat.termsig}"
  end
rescue Exception => e
  # TODO integrate to syslog
  ext_puts "Message: #{e.message}", "Stacktrace:", *e.backtrace

  exit 1
end


