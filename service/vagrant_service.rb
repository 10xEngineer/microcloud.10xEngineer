#!/usr/bin/env ruby

$stdout.sync = true

require 'ffi-rzmq'
require 'vagrant'
require 'yajl'

context = ZMQ::Context.new
socket = context.socket(ZMQ::REP)
socket.connect "ipc:///tmp/service.vagrant"

# FIXME refactor service core to a reusable class

loop do
  socket.recv_string(raw_message = '')

  message = Yajl::Parser.parse(raw_message)

  # TODO hardcoded part
  puts "-command-> #{message["command"]}"

  socket.send_string "{\"status\": \"ok\"}"
end

