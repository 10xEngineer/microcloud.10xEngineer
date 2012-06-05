#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'ffi-rzmq'
require 'yajl'
require 'foreman/procfile'
require 'utils/message'

procfile_name = File.join(File.dirname(__FILE__), 'Procfile')

unless File.exists?(procfile_name)
  puts "Procfile does not exists. Please, use foreman to start broker and services"
  exit
end

# service discovery (re-using Procfile definition)
procfile = Foreman::Procfile.new(procfile_name)

service_names = procfile.process_names
service_names.delete("broker")

# init 0mq
context = ZMQ::Context.new
frontend = context.socket(ZMQ::ROUTER)

frontend.bind "ipc:///tmp/mc.broker"

poller = ZMQ::Poller.new
poller.register(frontend, ZMQ::POLLIN)

# prepare service endpoints
services = {}
service_names.each do |name|
  service = {}
  service[:addr] = "ipc:///tmp/service.#{name}"

  service_socket = context.socket(ZMQ::DEALER)
  service_socket.bind(service[:addr])

  service[:socket] = service_socket

  poller.register(service_socket, ZMQ::POLLIN)

  services[name] = service
end

# helper - list of service sockets
sockets = services.values.collect { |service| service[:socket] }

loop do
  poller.poll(:blocking)
  poller.readables.each do |socket|
    if socket == frontend
      # frontend requests
      request = read_message(socket)

      message = Yajl::Parser.parse(request[:message])

      req_service = message["service"]

      if services.include?(req_service)
        service = services[req_service][:socket]

        send_message(service, request)
      else
        send_message(frontend, error_message(request, "Service not available (#{req_service})."))
      end
    elsif sockets.include?(socket)
      # response from registered service
      response = read_message(socket)
      
      send_message(frontend, response)
    else
      # TODO logging (or service supervise to collect stdout/stderr)
      puts "Unrecognized service!"
    end
  end
end
