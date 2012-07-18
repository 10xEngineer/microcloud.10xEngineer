#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'open4'
require 'utils'
require 'common/compile'

ext_puts "10xLabs receiving push"

data = process_push_data

begin
  # TODO the compilation
  ext_puts "Starting compilation service..."

  command = ["./10xlabs-compile.sh", data[:repo], data[:new_rev], data[:ref_name]]

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
end


