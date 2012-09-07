require 'erubis'
require 'tmpdir'

class LabBuilder
	TEMPLATE_DIR = File.join(File.dirname(__FILE__), "../templates")
	COMPONENTS = ['assets','components','config','cookbooks','integrations','vms']

	def initialize(metadata, git)
		@metadata = metadata
		@git = git
	end

	def build
		Dir.mktmpdir do |lab_dir|
			mk_cookbook_dirs(lab_dir)

			render_metadata_rb(lab_dir)

			@metadata.to_obj[:vms].each do |vm|
				render_vm_rb(lab_dir, vm)
			end
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

	def write_file(target, data)
		File.open(target, 'w') { |file| file.write(data)}
	end

	def render_template(name, bindings)
		file_name = "#{name}.erb"
		template = Erubis::Eruby.new File.read(File.join(TEMPLATE_DIR, file_name))

		template.result(bindings)
	end
end