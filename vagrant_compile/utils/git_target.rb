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

	def mk_temp_repo(location, remote_url)
		src_repo = Grit::Repo.init(location)
		index = Grit::Index.new(src_repo)

		# TODO try to add all files at once (*array)
		Dir.chdir(location) do
			Dir.glob("**/*").each do |f|
				src_repo.add(f)
			end
		end

		src_repo.commit_index("vaglab initial commit")

		src_repo.remote_add 'origin', remote_url
	end

	def push_temp(location)
		Dir.chdir(location) do
			# FIXME configurable git location
			cmd = ["git", "push", "origin", "master"]
			exec cmd.join(' ')
		end
	end
end

def git_repo?(dir)
	begin
		repo = Grit::Repo.new(dir)
	rescue Grit::InvalidGitRepositoryError
		return false
	end
end