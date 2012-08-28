#!/usr/bin/env ruby
require 'json'

full_attr = ARGV.shift
abort "Missing attribute name" unless full_attr

in_data = ARGF.readlines
abort "Missing input data" unless in_data

source_data = in_data.join

data = JSON.parse source_data
full_attr.split('.').each do |attr|
	data = data[attr]
end

puts data