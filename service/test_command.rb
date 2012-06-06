#!/usr/bin/env ruby

require 'ffi-rzmq'
require 'yajl'

context = ZMQ::Context.new(1)

# client should use REQ sockets
socket = context.socket ZMQ::REQ

# sample message
#request = {
#  :service => :dummy,
#  :action => :ping,
#  :options => {:say => "Hi!"}
#}

request = {
  :service => :ec2,
  :action => :stop,
  :options => {
    "secret_access_key" => "A5WK+zZbX/UMWTJ61XOVos/OFuYngEyaakQn8s7g",
    "access_key_id" => "AKIAI3OXTTB6BTF4EPCQ",
    "region" => "us-east-1",
    #"ami" => "ami-3202f25b",
    #"key" => "ec2-keypair",
    #"type" => "t1.micro"
    "id" => "i-0a11c573"
  }
}

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
