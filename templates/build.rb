#!/usr/bin/env ruby

$:.unshift(File.expand_path('..', __FILE__))

require 'utils/external'

# TODO dependencies (ie ubuntu-node depends on ubuntu-precise) - implicit ordering

def blueprints
	blueprints = []

	Dir.glob("blueprints/*").each {|dir| blueprints << File.basename(dir) if File.exists?(File.join(dir, "build.sh"))}

	return blueprints.sort
end

blueprints.each do |blueprint|
	cmd = []
	cmd << File.join(File.expand_path('.'), "blueprints/#{blueprint}/build.sh")
	cmd << blueprint

	blueprint_archive = File.join("dist", "#{blueprint}.tar.gz")
	if File.symlink?(blueprint_archive)
		puts "Skipping '#{blueprint}': already exists"
		next
	end

	begin
		TenxLabs::External::execute(cmd.join(' ')) do |line|
			puts "#{blueprint} >> #{line}"
		end
	rescue => e
		puts e.message

		Process.exit
	end
end
