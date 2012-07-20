#!/usr/bin/env ruby

repository = /([^\/]*?)\.git$/.match(`pwd`.chomp)[1]

stdins = []; stdins << $_ while gets

stdins.each do |str|
  # parse the stdin string
  arr = str.split
  refs = arr[2].split('/')
  
  oldrev   = arr[0] # SHA
  newrev   = arr[1] # SHA
  ref_type = refs[1] # tags || heads (branch)
  ref_name = refs[2] # develop, 1.4 etc.
  
  puts "New revision #{newrev}"
end