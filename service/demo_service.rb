#!/usr/bin/env ruby

$stdout.sync = true

require 'ffi-rzmq'

context = ZMQ::Context.new
socket = context.socket(ZMQ::REP)
socket.connect "ipc:///tmp/service.demo"

loop do
  socket.recv_string(message='')
  
  puts "-> #{message}"

  sleep 30
  
  socket.send_string "{\"status\": \"ok\"}"
end
