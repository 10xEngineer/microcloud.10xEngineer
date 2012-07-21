#!/usr/bin/env ruby

require 'yajl'

def get_lab_token(repo)
  metadata_file = File.join(ENV['HOME'], ".gitolite/10xlabs/metadata.json")
  
  raise "Unable to find gitolite/10xlabs metadata; invalid setup!" unless File.exists? metadata_file

  raw_data = File.read(metadata_file)
  metadata = Yajl::Parser.parse(raw_data)

  raise "Unable to find repository #{repo}" unless metadata.has_key? repo

  return {
    :lab_token => metadata[repo]["token"],
    :lab_name => metadata[repo]["lab_name"]
  }
end

def process_push_data
  # from # https://gist.github.com/478846
  repository = /([^\/]*?)\.git$/.match(`pwd`.chomp)[1]

  stdins = []; stdins << $_ while gets

  str = stdins.last
  arr = str.split
  refs = arr[2].split('/')
  
  oldrev   = arr[0] #
  newrev   = arr[1] #
  ref_type = refs[1] # tags || heads (branch)
  ref_name = refs[2] # develop, 1.4 etc.

  {
    :repo => repository,
    :old_rev => oldrev,
    :new_rev => newrev,
    :ref_type => ref_type,
    :ref_name => ref_name
  }
end

def ext_puts(*obj)
  obj.each do |o|
    if obj.index(o) == 0
      print trailing_sym
    else
      print trailing_sym(' ', ' ')
    end
    
    puts o
  end

  nil
end

def ext_puts_x(*obj)
  obj.each do |o|
    print trailing_sym(' ', ' ')
    
    puts o
  end

  nil
end

def trailing_sym(fill_char = '-', append = '>', length = 8)
  fill_len = length - append.length
  fill_len = 0 if fill_len < 0

  output = fill_char * fill_len
  output << append
  output << ' '
end