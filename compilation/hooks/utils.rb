#!/usr/bin/env ruby

def process_push_data
  # from # https://gist.github.com/478846
  repository = /([^\/]*?)\.git$/.match(`pwd`.chomp)[1]

  stdins = []; stdins << $_ while gets
  stdins.each do |str|
    arr = str.split
    refs = arr[2].split('/')
    
    oldrev   = arr[0] #
    newrev   = arr[1] #
    ref_type = refs[1] # tags || heads (branch)
    ref_name = refs[2] # develop, 1.4 etc.
    
    puts "New revision #{newrev}"  
  end

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

def trailing_sym(fill_char = '-', append = '>', length = 8)
  fill_len = length - append.length
  fill_len = 0 if fill_len < 0

  output = fill_char * fill_len
  output << append
  output << ' '
end