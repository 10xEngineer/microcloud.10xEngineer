#!/usr/bin/env ruby

require 'ffi-rzmq'

context = ZMQ::Context.new(1)
socket = context.socket ZMQ::REQ

#socket.setsockopt ZMQ::IDENTITY, "testclient"

# TODO #socket structure

socket.connect "ipc:///tmp/mc.broker"
#socket.bind "ipc:///tmp/service.demo"
socket.send_string "test-message"
socket.recv_string(reply = '')

puts "response = #{reply}"
