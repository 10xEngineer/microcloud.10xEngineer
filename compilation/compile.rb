#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)
$stdout.sync = true

require 'grit'
require 'tmpdir'
require 'fileutils'
require 'definition/metadata'

def prepare_repo(source)
  # FIXME hardcoded for now
  # FIXME hardcoded repo (should be resolved from name)
  repo = "ssh://#{source}"

  temp_dir = Dir.mktmpdir
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

# parse arguments
repo = ARGV.shift
lab_token = ARGV.shift
repo_rev = ARGV.shift
repo_ref = ARGV.shift

# get repository
repo_dir = prepare_repo(repo)
puts "Compile environment ready."

# verify pre-requisuites
metadata_rb = File.join(repo_dir, 'metadata.rb')
unless File.exists? metadata_rb
  warn "Invalid lab definition: no metadata.rb"

  exit 1
end

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

# push to microcloud
# FIXME how to lookup lab definition
# => git url is located within lab definition
# => implicit authentication


# remove fragments
FileUtils.rm_rf repo_dir
puts "Compilation fragments removed."

