require 'grit'

class GitTarget
	def initialize(target)
		@target = target

		begin
			@repo = Grit::Repo.new(target)	
		rescue Grit::InvalidGitRepositoryError
			puts "Target is not a git repository." 
			puts
			puts "Currently only GIT-based projects are supported."
			abort
		end
	end

	def user_name
		@repo.config["user.name"]
	end

	def user_email
		@repo.config["user.email"]
	end

	def origin_url
		# TODO currently hardcoded to use 'origin' only
		ref = "origin"

		remotes = @repo.remote_list
		raise "No origin defined!" unless remotes.include? ref

		@repo.config["remote.#{ref}.url"]
	end
end

def git_repo?(dir)
	begin
		repo = Grit::Repo.new(dir)
	rescue Grit::InvalidGitRepositoryError
		return false
	end
end