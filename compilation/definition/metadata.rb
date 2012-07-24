require 'definition/mixins/transform'
require 'pathname'

class Metadata
  include TenxLabs::Mixin::ObjectTransform

  attr_accessor :maintainer, :maintainer_email, :handler, :version, :description

  # FIXME provide chef style set_or_return with validations (chef/mixin/params_validate.rb)
  # FIXME DRY way how to define attributes/assign/evaluate
  # FIXME translate into JSON structure (mixin?)
  # FIXME lookup handler (initially Chef only)
  # FIXME revision must not be specified in metadata directly

  def initialize(metadata_rb, revision = nil)
    @metadata_rb = metadata_rb

    @maintainer = nil
    @maintainer_email = nil
    @handler = nil
    @version = nil
    @description = nil
    @revision = revision

    @vms = []

    # internal definition structure
    @vms_path = "vms"
  end

  def evaluate
    self.instance_eval(IO.read(@metadata_rb), @metadata_rb)

    evaluate_vms
  end

  def use(handler_klass)
    @handler = handler_klass
  end

  def maintainer(maintainer)
    @maintainer = maintainer
  end

  def maintainer_email(email)
    @maintainer_email = email
  end

  def version(ver)
    @version = ver
  end

  def long_description(desc)
    @description = desc
  end

  def vms_path(vms_path)
    @vms_path = vms_path
  end

  def to_obj
    {
      :__type__ => self.class.to_s.underscore,
      :version => @version,
      :revision => @revision,
      :maintainer => @maintainer,
      :maintainer_email => @maintainer_email,
      :handler => @handler,
      :description => @description,
      :vms => @vms.map {|vm| vm.to_obj}
    }
  end

private

  def evaluate_vms
    full_vms_path = nil
    if @vms_path.match /^\//
      full_vms_path = File.join(@vms_path, "*.rb")
    else
      full_vms_path = File.join(base_dir, @vms_path, "*.rb")
    end

    # read manual @vms_path/*.rb
    Dir.glob(full_vms_path).each do |file|
      # evaluate individual files
      vm = Vm.class_eval(IO.read(file), file)

      @vms << vm
    end
  end

  def base_dir
    Pathname.new(@metadata_rb).dirname
  end
end
