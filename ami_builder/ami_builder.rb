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

abort "Region not supported by ami_builder/invalid (#{aws_region})" unless TenxEngineer::SOURCE_AMI[:ubuntu][aws_region]

aws = Fog::Compute.new({
  :provider => 'AWS',
  :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
  :region => aws_region
})

puts "AWS connection established."

# create server
base = aws.servers.create(:flavor_id => "m1.small",
                         :image_id => TenxEngineer::SOURCE_AMI[:ubuntu][aws_region],
                         :key_name => key_name,
                         :security_group_ids => "tenxlab_node")

puts "Instance start request accepted - instance #{base.id}"

# wait for instance
print "Waiting for instance to become operational"

base.wait_for do
  sleep 5
  print '.'

  ready?
end

puts
puts "Instance ready (#{base.dns_name})"

sleep 30

# copy postinstall.sh to server
Net::SCP.start(base.dns_name, 'ubuntu') do |scp|
  scp.upload! File.join(File.dirname(__FILE__), 'definition/postinstall.sh'), '/tmp/'
end

puts "****** post-install"

# run postinstall
ssh_exec('ubuntu', base.dns_name, "cd /tmp && chmod 0775 postinstall.sh && ./postinstall.sh", {}, true)

puts 
puts "****** post-install finished"

# create image
puts "Initiating AMI"
timestamp = Time.now.utc.strftime("%y%m%d")
image_name = "labs-precise64-#{timestamp}"
image_desc = "10xEngineer Labs based AMI (Ubuntu 12.10 based)"

ami = aws.create_image(base.identity, image_name, image_desc)
image_id = ami.body['imageId']

sleep 30

print "Waiting for image #{image_id} to be created"
while (aws.images.get(image_id).state != "available") do
  sleep 5
  print '.'
end

puts "EBS backed AMI #{image_id} available."
puts 

base.destroy
puts "Instance terminated."
