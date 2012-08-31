#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'utils/provider'
require "utils/config"
require 'ffi-rzmq'
require 'net/ssh'
require 'mongoid'
require 'logger'
require 'yaml'
require 'yajl'

log = Logger.new(STDOUT)
log.level = Logger::WARN

if ARGV.length == 0
  puts "service name missing"
  exit
end

service_name = ARGV.shift

# load config
if ENV['MICROCLOUD_ENV'] == 'production'
  config_file = '/etc/10xlabs-hostnode.yaml'
else
  config_file = File.join(File.dirname(__FILE__), "../config/10xlabs-hostnode.yaml")
end

config = TenxEngineer.config(config_file)

# configure mongoid
unless ENV["MONGOID_ENV"] || ENV["RACK_ENV"] 
  ENV["MONGOID_ENV"] = "development"
end

Mongoid.load!(File.join(File.dirname(__FILE__), "mongoid.yml"))

# load service
service_file = File.join(File.dirname(__FILE__), "providers/#{service_name}.rb")
unless File.exists?(service_file)
  puts "invalid service name '#{service_name}'"
  exit
end

service = Provider.load_service(service_name, config)

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
  response = service.fire(action, request, socket)
end
