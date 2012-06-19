#!/usr/bin/env ruby

require 'ffi-rzmq'
require 'yajl'

context = ZMQ::Context.new(1)

# client should use REQ sockets
socket = context.socket ZMQ::REQ

# sample message
#request = {
#  :service => :dummy,
#  :action => :ping
#}
#
request = {
  :service => :lxc,
  :action => :start,
  :options => {
    :server => "vagrant.local",
    :id => "8b946490-9bfc-012f-c15c-0800272cf3a1",
  }
}

#request = {
#  :service => :ec2,
#  :action => :start,
#  :options => {
#    "secret_access_key" => "nBVSF7hBS7uutlbO4ZT77mHKGTJKbg5+ANjNZzWz",
#    "access_key_id" => "AKIAJIPBWGE6PG5C2VGA",
#    "region" => "eu-west-1",
#    "ami" => "ami-77f0f503",
#    "key" => "europe-default",
#    #"type" => "t1.micro"
#    #"id" => "i-0a11c573"
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
