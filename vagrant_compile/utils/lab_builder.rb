require 'erubis'
require 'tmpdir'
require '10xlabs/microcloud'

class LabBuilder
	TEMPLATE_DIR = File.join(File.dirname(__FILE__), "../templates")

	# TODO data_bags are only temporarily used before replaced by substite-10xlabs data provider
	COMPONENTS = ['assets','components','config','cookbooks','data_bags','integrations','roles','vms']

	def initialize(vagrant_env, metadata, git)
		@vagrant_env = vagrant_env
		@metadata = metadata
		@git = git

		endpoint = ENV['MICROCLOUD'] || "http://mc.apac.external.10xlabs.net"

		puts "Using 10xlabs endpoint #{endpoint}"

		@microcloud = TenxLabs::Microcloud.new(endpoint)
	end

	def build
		Dir.mktmpdir do |lab_dir|
			puts "Temporary location: #{lab_dir}"

			# prepare basic layout & files
			mk_cookbook_dirs(lab_dir)

			render_metadata_rb(lab_dir)

			@metadata.to_obj[:vms].each do |vm|
				render_vm_rb(lab_dir, vm)
			end

			puts 'Copying cookbooks...'

			# copy cookbooks files into <lab>/cookbooks
			cookbooks_target = File.join(lab_dir, "cookbooks/")
			cookbook_paths.each do |path|
				copy_files(path, cookbooks_target)
			end

			# copy roles
			roles = roles_path 
			if roles 
				puts "Copying roles..."

				roles_target = File.join(lab_dir, "roles/")
				copy_files(roles, roles_target)
			end

			# data bags
			# TODO temporary (to maintain chef-compatability)
			bags = data_bags_path
			if bags
				puts "Copying data bags..."

				data_bags_target = File.join(lab_dir, "data_bags")
				copy_files(bags, data_bags_target)
			end

			# create lab
			# TODO get the lab name from directory name
			# TODO how to resolve pool
			data = {
				:name => "xx4",
				:pools => {:compute => "xxxtest"}
			}

			res = @microcloud.post(:labs, nil, data)
			# res["repo"]

			# init repository
			puts "Preparing source repository..."
			@git.mk_temp_repo(lab_dir, res["repo"])

			puts "Pushing to 10xLabs..."
			@git.push_temp(lab_dir)

		end
	end

	def mk_cookbook_dirs(target)
		COMPONENTS.each do |a_dir|
			dir = File.join(target, a_dir)

			Dir::mkdir(dir)
		end
	end

	def render_metadata_rb(lab_dir)
		result = render_template("metadata.rb", {:metadata => @metadata.to_obj})

		write_file(File.join(lab_dir, 'metadata.rb'), result)
	end

	def render_vm_rb(lab_dir, vm)
		result = render_template("vm.rb", {:vm => vm})

		vm_dir = File.join(lab_dir, "vms")
		write_file(File.join(vm_dir, "#{vm[:name]}.rb"), result)
	end


private

	def cookbook_paths
		paths = []

		# FIXME handle missing provisioners
		_paths = @vagrant_env.config.for_vm(:default).keys[:vm].provisioners[0].config.cookbooks_path
		_paths.each do |path|
			paths << expand_path(path)
		end

		paths
	end

	def roles_path
		expand_path @vagrant_env.config.for_vm(:default).keys[:vm].provisioners[0].config.roles_path
	end

	def data_bags_path
		expand_path @vagrant_env.config.for_vm(:default).keys[:vm].provisioners[0].config.data_bags_path
	end

	def write_file(target, data)
		File.open(target, 'w') { |file| file.write(data)}
	end

	def render_template(name, bindings)
		file_name = "#{name}.erb"
		template = Erubis::Eruby.new File.read(File.join(TEMPLATE_DIR, file_name))

		template.result(bindings)
	end

	def copy_files(path, target)
		FileUtils.cp_r(path, target)
	end	

	def expand_path(path)
		return nil unless path

		if path =~ /^(\/|\~\/)/
			return "#File.expand_path(path)}/"
		else
			# /. suffix prevents cp_r to create src/dest (ie cookbooks/cookbooks, or roles/roles)
			# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/fileutils/rdoc/FileUtils.html#method-c-cp_r
			return "#{File.join(@vagrant_env.cwd.to_s, path)}/."
		end
	end
end