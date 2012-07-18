require 'definition/mixins/transform'

class Metadata
  include TenxLabs::Mixin::ObjectTransform

  attr_accessor :maintainer, :maintainer_email, :handler, :version, :description

  # FIXME provide chef style set_or_return with validations (chef/mixin/params_validate.rb)
  # FIXME DRY way how to define attributes/assign/evaluate
  # FIXME translate into JSON structure (mixin?)
  # FIXME lookup handler (initially Chef only)

  def initialize(metadata_rb)
    @metadata_rb = metadata_rb

    @maintainer = nil
    @maintainer_email = nil
    @handler = nil
    @version = nil
    @description = nil
  end

  def evaluate
    self.instance_eval(IO.read(@metadata_rb), @metadata_rb)
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

  def to_obj
    {
      :version => @version,
      :maintainer => @maintainer,
      :maintainer_email => @maintainer_email,
      :handler => @handler,
      :description => @description
    }
  end
end
