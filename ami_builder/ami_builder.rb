#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'config'
# FIXME create shared package (ssh both for service and ami_builder)
require 'ssh'
require 'fog'
require 'net/ssh'
require 'net/scp'

abort "EC2 credentials are missing!" unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']

if ARGV.length < 2
  abort "usage: ami_builder.rb region keyname"
end

# establish connection
aws_region = ARGV.shift
key_name = ARGV.shift

abort "Region not supported by ami_builder/invalid (#{aws_region})" unless TenxEngineer::SOURCE_AMI[aws_region]

aws = Fog::Compute.new({
  :provider => 'AWS',
  :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
  :region => aws_region
})

puts "AWS connection established."

# create server
base = aws.servers.create(:flavor_id => "m1.small",
                         :image_id => TenxEngineer::SOURCE_AMI[aws_region],
                         :key_name => key_name)

puts "Instance start request accepted - instance #{base.id}"

# wait for instance
print "Waiting for instance to become operational"

base.wait_for do
  print '.'
  ready? 
end

puts

puts "Instance ready (#{base.dns_name})"

sleep 15

# copy postinstall.sh to server
Net::SCP.start(base.dns_name, 'ubuntu') do |scp|
  scp.upload! File.join(File.dirname(__FILE__), 'definition/postinstall.sh'), '/tmp/'
end

# run postinstall
ssh_exec('ubuntu', base.dns_name, "cd /tmp && chmod 0775 postinstall.sh && ./postinstall.sh", {}, true)

# TODO continue - create AMI
# TODO shutdown instance
