#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'grit'
require 'tmpdir'
require 'fileutils'
require 'definition/metadata'
require '10xlabs/microcloud'

def prepare_repo(temp_dir, repo)
  repo = "ssh://#{repo}" unless repo.match /^ssh\:\/\//

  git = Grit::Git.new(".")

  options = {
    :quiet => false,
    :verbose => true,
    :progress => true,
    :branch => "master"
  }

  git.clone(options, repo, temp_dir)

  temp_dir
end

Dir.mktmpdir do |repo_dir|
  # parse arguments
  repo = ARGV.shift
  lab_name = ARGV.shift
  lab_token = ARGV.shift
  repo_rev = ARGV.shift
  repo_ref = ARGV.shift

  # get repository
  prepare_repo(repo_dir, repo)
  puts "Compile environment ready."

  # verify pre-requisuites
  metadata_rb = File.join(repo_dir, "metadata.rb")
  unless File.exists? metadata_rb
    puts "Invalid lab definition: no metadata.rb"

    # FIXME exit 1 aborts the push 
    # FIXME need to find more elegant solution
  else
    # read metadata
    m = Metadata.new(metadata_rb)
    begin 
      m.evaluate
    rescue Exception => e
      puts "Metadata evaluation failed: #{e.message}"

      exit 99
    end

    json_def = m.to_json
    puts "Temporary definition output:"

    @microcloud = TenxLabs::Microcloud.new("http://bunny.laststation.net:8080/")
    # TODO get lab name
    #lab = @microcloud.post_ext("")

    # lab definition
    puts json_def
  end
end

# push to microcloud
# FIXME how to lookup lab definition
# => git url is located within lab definition
# => implicit authentication


# FIXME ensure cleanup on failure too
# remove fragments
puts "Compilation fragments removed."

