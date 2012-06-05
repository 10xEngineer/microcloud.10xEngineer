#!/usr/bin/env ruby

require 'ffi-rzmq'
require 'yajl'

context = ZMQ::Context.new(1)
socket = context.socket ZMQ::REQ

#socket.setsockopt ZMQ::IDENTITY, "testclient"


request = {
  :context => :server,
  :command => :create,
  :provider => :vagrant
}

socket.connect "ipc:///tmp/mc.broker"
socket.send_string Yajl::Encoder.encode(request)
socket.recv_string(reply = '')

puts "response = #{reply}"
