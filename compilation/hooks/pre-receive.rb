#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'open4'
require 'utils'
require 'yajl'
require 'microcloud'

ext_puts "10xLabs receiving push"

data = process_push_data

begin
  ext_puts "Starting compilation service..."

  # retrieve lab token
  res = get_lab_token(data[:repo])
  lab_token = res[:lab_token]
  lab_name = res[:lab_name]

  # build git repository URL
  config = File.join(ENV['HOME'], '.10xlab-repo')
  if File.exist? config
    repo_prefix = IO.read(config).strip
  else
    io = IO.popen('hostname')
    host_raw = io.readlines.first.strip

    repo_prefix = "#{ENV['USER']}@#{host_raw}"
  end

  # TODO pre-receive hook is not getting references when using clone from remote repository
  # TODO consider cloning local repository (shared via some kind of networking system)
  # https://trello.com/card/gitolite-pre-receive-hook/50067c2712a969ae032917f4/21
  repo = "#{repo_prefix}/#{data[:repo]}"

  # read config
  config = Yajl::Parser.parse("/home/git/.compile.conf")

  microcloud = TenxLabs::Microcloud.new(config["endpoint"])

  compile_data = {
    :comp_kit => "10xlabs-definition", 
    :source_url => repo, 
    :pub_key => "not_defined", 
    :args => [lab_name, lab_token, data[:new_rev]]
  }
  res = microcloud.post_ext "/sandboxes/compile", compile_data
rescue Exception => e
  # TODO integrate to syslog
  ext_puts "Message: #{e.message}", "Stacktrace:", *e.backtrace

  exit 1
end


