#!/usr/bin/env ruby

require 'ffi-rzmq'

context = ZMQ::Context.new(1)
req = context.socket ZMQ::REQ

# TODO socket structure
req.connect "ipc:///tmp/mc.broker"

req.send_string "test-message"

reply = ''
req.recv_string reply

puts "response = #{reply}"
