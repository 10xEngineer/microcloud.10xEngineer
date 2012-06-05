#!/usr/bin/env ruby

require 'ffi-rzmq'

context = ZMQ::Context.new
socket = context.socket(ZMQ::REP)
socket.connect "ipc:///tmp/service.demo"

loop do
  socket.recv_string(message='')
  
  puts "-> #{message}"
  
  socket.send_string "{\"status\": \"ok\"}"
end
