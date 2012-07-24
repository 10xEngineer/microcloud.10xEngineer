#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'grit'
require 'tmpdir'
require 'fileutils'
require 'definition/metadata'
require 'definition/vm'
require '10xlabs/microcloud'

def prepare_repo(temp_dir, repo, rev = nil)
  repo = "ssh://#{repo}" unless repo.match /^ssh\:\/\//

  git = Grit::Git.new(".")

  options = {
    :quiet => false,
    :verbose => true,
    :progress => true,
    :branch => "master"
  }

  git.clone(options, repo, temp_dir)

  if rev
    repo = Grit::Repo.new(temp_dir)
    repo.git.run("", "checkout", "", {}, [rev])
  end

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
  prepare_repo(repo_dir, repo, repo_rev)
  puts "Compile environment ready."

  #repo_dir = "/Users/radim/tmp/labs/source"

  # verify pre-requisuites
  metadata_rb = File.join(repo_dir, "metadata.rb")
  unless File.exists? metadata_rb
    puts "Invalid lab definition: no metadata.rb"

    # FIXME exit 1 aborts the push 
    # FIXME need to find more elegant solution
  else
    # read metadata
    m = Metadata.new(metadata_rb, repo_rev)
    begin 
      m.evaluate
    rescue Exception => e
      puts "Metadata evaluation failed: #{e.message}"

      exit 99
    end

    json_def = m.to_json
    puts "Temporary definition output:"

    puts json_def

    # push to microcloud
    # TODO handle return code
    # TODO security model
    @microcloud = TenxLabs::Microcloud.new("http://bunny.laststation.net:8080/")
    lab = @microcloud.post_ext("/labs/#{lab_name}/versions", m.to_obj)
  end
end

# push to microcloud
# FIXME how to lookup lab definition
# => git url is located within lab definition
# => implicit authentication


# FIXME ensure cleanup on failure too
# remove fragments
puts "Compilation fragments removed."

