require 'definition/mixins/transform'

class Vm
  include TenxLabs::Mixin::ObjectTransform

  attr_accessor :name

  def initialize(name, &block)
    @name = name
    @file = nil

    @base_image = nil
    @hostname = nil
    @run_list = []

    instance_eval &block
  end

  def self.vm(name, &block)
    Vm.new(name, &block)
  end

  def base_image(image)
    @base_image = image
  end

  def hostname(hostname)
    @hostname = hostname
  end

  def run_list(list)
    @run_list = list
  end

  def to_obj
    {
      :__type__ => self.class.to_s.underscore,
      :name => @name,
      :vm_type => @base_image,
      :hostname => @hostname,
      :run_list => @run_list
    }
  end
end