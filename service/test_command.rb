#!/usr/bin/env ruby

require 'ffi-rzmq'
require 'yajl'

context = ZMQ::Context.new(1)

# client should use REQ sockets
socket = context.socket ZMQ::REQ

#socket.setsockopt(ZMQ::LINGER, 0, 8)

#poller = ZMQ::Poller.new
#poller.register(socket, ZMQ::POLLOUT)

# sample message
#request = {
#  :service => :lxc,
#  :action => :ping
#}

#request = {
#  :service => :key,
#  :action => :create
#}

#request = {
#	:service => :git_adm,
#	:action => :archive_to_file,
#	:options => {
#		:repo => "ssh://tenx@bunny.laststation.net:440/263f0030-d317-012f-e1b2-58b035f9777f"
#	}
#}

#
request = {
  :service => :lxc,
  :action => :create,
  :options => {
    :server => "tenxeng-precise32",
    :template => "ubuntu-precise64",
    :defer => true
  }
}

#request = {
#  :service => :loop,
#  :action => :prepare,
#  :options => {
#    :server => "test.local"
#  }
#}

#request = {
#  :service => :git_adm,
#  :action => :create_repo,
#  :options => {
#    :name => "labxxx"
#  }
#}

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
#socket.connect "ipc:///tmp/taskeng"
socket.connect "ipc:///tmp/mc.broker"

1.times do 
  # send message
  socket.send_string message
  puts "-> #{message}" 

  # wait for response (blocking in this case)
  socket.recv_string(reply = '')

  puts "<- #{reply}"
end
