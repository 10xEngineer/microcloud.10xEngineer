#!/usr/bin/env ruby

require 'ffi-rzmq'
require 'yajl'

context = ZMQ::Context.new(1)

# client should use REQ sockets
socket = context.socket ZMQ::REQ

# sample message
request = {
  :service => :dummy,
  :action => :ping,
  :options => {:say => "Hi!"}
}

#request = {
#  :service => :vagrant,
#  :action => :status,
#  :options => {
#    :env => "/Users/radim/Projects/10xeng/microcloud.10xEngineer/a_vagrant_machine"
#  }
#}

message = Yajl::Encoder.encode(request)

# local unix domain used for connection
# should be configurable (as it might change once we got further deployment details)
socket.connect "ipc:///tmp/mc.broker"

# send message
socket.send_string message

puts "-> #{message}" 

# wait for response (blocking in this case)
socket.recv_string(reply = '')

puts "<- #{reply}"
