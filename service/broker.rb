#!/usr/bin/env ruby

require 'ffi-rzmq'

context = ZMQ::Context.new
frontend = context.socket(ZMQ::ROUTER)

frontend.bind "ipc:///tmp/mc.broker"

# TODO hardcoded services
demo_service = context.socket(ZMQ::DEALER)
demo_service.bind "ipc:///tmp/service.demo"

poller = ZMQ::Poller.new
poller.register(frontend, ZMQ::POLLIN)
poller.register(demo_service, ZMQ::POLLIN)

protocol = [:address, nil, :message]

loop do
  poller.poll(:blocking)
  poller.readables.each do |socket|
    if socket == frontend
      request = {}
      msg_pos = 0

      begin 
        socket.recv_string(raw_message = '')

        request[protocol[msg_pos]] = raw_message unless protocol[msg_pos].nil?
        msg_pos = msg_pos + 1
      end while socket.more_parts?

      # TODO continue
      puts request.inspect

      # TODO multiplex commands to individual workers
      demo_service.send_string request[:address], ZMQ::SNDMORE
      demo_service.send_string '', ZMQ::SNDMORE
      demo_service.send_string request[:message], 0
    end
    if socket == demo_service
      response = {}
      msg_pos = 0

      begin 
        socket.recv_string(raw_message = '')

        response[protocol[msg_pos]] = raw_message unless protocol[msg_pos].nil?
        msg_pos = msg_pos + 1
      end while socket.more_parts?

      puts '--> from service'
      puts response[:message]

      frontend.send_string response[:address], ZMQ::SNDMORE
      frontend.send_string '', ZMQ::SNDMORE
      frontend.send_string response[:message], 0
    end
  end
end
