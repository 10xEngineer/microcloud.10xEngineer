#!/usr/bin/env ruby

$stdout.sync = true

require 'ffi-rzmq'
require 'yajl'

context = ZMQ::Context.new
frontend = context.socket(ZMQ::ROUTER)

frontend.bind "ipc:///tmp/mc.broker"

poller = ZMQ::Poller.new
poller.register(frontend, ZMQ::POLLIN)

# service definition (refactored, but still hardcoded)
services = {
  :demo => {:addr => "ipc:///tmp/service.demo"},
  :vagrant => {:addr => "ipc:///tmp/service.vagrant"}
}

services.keys.each do |service_name|
  service = context.socket(ZMQ::DEALER)
  service.bind(services[service_name][:addr])

  poller.register(service, ZMQ::POLLIN)

  services[service_name][:socket] = service
end

# list of service sockets
sockets = services.values.collect { |service| service[:socket] }

def read_message(socket)
  zmq_format = [:address, nil, :message]

  message = {}
  position = 0
  begin
    socket.recv_string(raw_message = '')
    message[zmq_format[position]] = raw_message unless zmq_format[position].nil?

    position = position + 1
  end while socket.more_parts?

  message
end


loop do
  poller.poll(:blocking)
  poller.readables.each do |socket|
    if socket == frontend
      request = read_message(socket)

      message = Yajl::Parser.parse(request[:message])

      # TODO validate service name
      service = services[message["context"].to_sym][:socket]

      service.send_string request[:address], ZMQ::SNDMORE
      service.send_string '', ZMQ::SNDMORE
      service.send_string request[:message], 0
    elsif sockets.include?(socket)
      # response from registered service
      
      response = read_message(socket)
      
      frontend.send_string response[:address], ZMQ::SNDMORE
      frontend.send_string '', ZMQ::SNDMORE
      frontend.send_string response[:message], 0
    else
      # TODO proper logging
      puts "Unrecognized service!"
    end
  end
end
