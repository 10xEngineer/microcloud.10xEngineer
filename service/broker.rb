#!/usr/bin/env ruby

require 'ffi-rzmq'

context = ZMQ::Context.new
frontend = context.socket(ZMQ::ROUTER)

frontend.bind "tcp://*:5559"

poller = ZMQ::Poller.new
poller.register(frontend, ZMQ::POLLIN)

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

      puts request.inspect
    end
  end
end
