#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'utils'
require 'common/compile'

def raise_hell
  raise "hell on earth"
end

ext_puts "10xLabs receiving push"

#data = process_push_data

begin
  # TODO the compilation
  raise_hell
rescue Exception => e
  # TODO integrate to syslog
  ext_puts "Doh! something bad happend", "Message: #{e.message}", "Stacktrace:", *e.backtrace
end


