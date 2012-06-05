#!/usr/bin/env ruby

require 'ffi-rzmq'
require 'yajl'

context = ZMQ::Context.new(1)
socket = context.socket ZMQ::REQ

request = {
  :service => :dummy,
  :action => :ping,
  :options => {:say => "Hi!"}
}

message = Yajl::Encoder.encode(request)

socket.connect "ipc:///tmp/mc.broker"
socket.send_string message

puts "-> #{message}" 

socket.recv_string(reply = '')

puts "<- #{reply}"
