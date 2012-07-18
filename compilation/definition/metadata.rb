class Metadata
  attr_accessor :maintainer, :maintainer_email, :handler, :version, :description

  # FIXME provide chef style set_or_return with validations (chef/mixin/params_validate.rb)

  def initialize(metadata_rb)
    @metadata_rb = metadata_rb
  end

  def evaluate
    self.instance_eval(IO.read(@metadata_rb), @metadata_rb)
  end

  def use(handler_klass)
  end

  def maintainer(maintainer)
  end

  def maintainer_email(email)
  end

  def version(ver)
  end

  def long_description(long_description)
  end
end
