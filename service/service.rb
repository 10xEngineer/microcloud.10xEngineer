#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'utils/provider'
require 'ffi-rzmq'
require 'yajl'

if ARGV.length == 0
  puts "service name missing"
  exit
end

service_name = ARGV.shift

service_file = File.join(File.dirname(__FILE__), "providers/#{service_name}.rb")
unless File.exists?(service_file)
  puts "invalid service name '#{service_name}'"
  exit
end

service = Provider.load_service(service_name)

# create 0mq socket
context = ZMQ::Context.new

socket = context.socket(ZMQ::REP)
socket.connect "ipc:///tmp/service.#{service_name}"

puts "Service '#{service_name}' started..."

loop do
  socket.recv_string(message = '')

  request = Yajl::Parser.parse(message)

  puts "service=#{request["service"]} action=#{request["action"]}"

  # provide options if not available
  request["options"] ||= {}

  action = request["action"]
  response = service.fire(action, request)

  socket.send_string Yajl::Encoder.encode(response)
end
