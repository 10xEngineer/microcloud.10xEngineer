#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'grit'
require 'tmpdir'
require 'fileutils'
require 'definition/metadata'

def prepare_repo(temp_dir, repo)
  repo = "ssh://#{repo}" unless repo.match /^ssh\:\/\//
  puts "Cloning #{repo}"

  git = Grit::Git.new(temp_dir)

  options = {
    :quiet => false,
    :verbose => true,
    :progress => true,
    :branch => "master"
  }

  git.clone(options, repo, temp_dir)

  temp_dir
end

repo_dir = Dir.mktmpdir

# parse arguments
repo = ARGV.shift
lab_token = ARGV.shift
repo_rev = ARGV.shift
repo_ref = ARGV.shift

# get repository
prepare_repo(repo_dir, repo)
puts "Compile environment ready."

# verify pre-requisuites
metadata_rb = File.join(repo_dir, 'metadata.rb')
unless File.exists? metadata_rb
  warn "Invalid lab definition: no metadata.rb"

  # FIXME exit 1 aborts the push 
  # FIXME need to find more elegant solution
else
  # read metadata
  m = Metadata.new(metadata_rb)
  begin 
    m.evaluate
  rescue Exception => e
    warn "Metadata evaluation failed: #{e.message}"

    exit 99
  end

  json_def = m.to_json
  puts "Temporary definition output:"
  puts json_def
end

# push to microcloud
# FIXME how to lookup lab definition
# => git url is located within lab definition
# => implicit authentication


# FIXME ensure cleanup on failure too
# remove fragments
FileUtils.remove_entry_secure repo_dir
puts "Compilation fragments removed."

