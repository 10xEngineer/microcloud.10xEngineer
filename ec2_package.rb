#!/usr/bin/env ruby
#Make a tarball of only the recipes called in dna.json
#Takes as an argument the path to a Vagrant VM's folder.
require 'rubygems'
require 'json'

print "\n"
print "ec2_package: about to parse Vagrantfile and compose dna.json and .cookbooks_path.json"
print "\n"
STDOUT.flush

Dir.chdir(ARGV[0]) do
  #run vagrant to parse the `Vagrantfile` and write out `dna.json` and `.cookbooks_path.json`.
  res = `vagrant`
  if $?.exitstatus != 0
    puts res
    exit 1
  end
  CookbooksPath = [JSON.parse(open('.cookbooks_path.json').read)].flatten
  print "\n"
  print "ec2_package: CookbooksPath = [", CookbooksPath.join(", "), "]"
  print "\n"
  STDOUT.flush
  
  recipe_names = JSON.parse(open('dna.json').read)["run_list"].map{|x|
    x.gsub('recipe', '').gsub(/(\[|\])/, '').gsub(/::.*$/, '')
  }.uniq

  open('recipe_list', 'w'){|f|
    f.puts recipe_names.map{|x|
      
      paths = CookbooksPath.map{|cookbook_path|
        "#{cookbook_path}/#{x}"
      }
      paths.reject!{|path| not File.exists?(path)}
      
      raise "Multiple cookbooks '#{x}' exist within `chef.cookbooks_path`; I'm not sure which one to use" if paths.length > 1
      raise "I can't find any cookbooks called '#{x}'" if paths.length == 0
      
      paths[0]
    }
  }
  
  print "\n"
  print "ec2_package: about to create cookbooks.tgz"
  print "\n"
  STDOUT.flush
  
  #Have tar chop off all of the relative file business prefixes so we can just
  #upload everything to the same cookbooks directory
  transforms = CookbooksPath.map{|path| "--transform=s,^#{path.gsub(/^\//, '')},cookbooks, "}
  #NOTE: the original is for gnu linux tar, which is not supported by macosx
  # for MacOSX, brew install gnu-tar which gives --from-files support but --transform needs to be handled as a separate sed operation
  unamestr=`uname -s`
  if [[ "$unamestr" == 'Darwin' ]]; then # MacOSX
    `gtar czf cookbooks.tgz --files-from recipe_list #{transforms*' '} `
  else # elif [[ "$unamestr" == 'Linux' ]]; then # Other Linux variants
     `tar czf cookbooks.tgz --files-from recipe_list #{transforms*' '} `
  end
  `rm recipe_list`  

#  `tar czf cookbooks.tgz --files-from recipe_list #{transforms*' '} 2> /dev/null`
  
  print "\n"
  print "ec2_package: done"
  print "\n"
  STDOUT.flush
  
end
