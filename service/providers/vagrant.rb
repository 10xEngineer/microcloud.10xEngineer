require 'utils/virtualbox'
require 'vagrant'

class VagrantService < Provider
  # TODO logic for options validation
  # TODO support for multi-VM setups

  # TODO it should already be running in vagrant!!
  #      TenxEngineer::VirtualBox.detect?
  # TODO add multi-vm support
  def start(request)
    # already running in Vagrant (no work necessary)
    #raise "Vagrant environment (env) not specified" unless request["options"].include?("env")

    #env = Vagrant::Environment.new(:cwd => request["options"]["env"])
    #vm = env.vms[:default]

    #unless env.vms[:default].created?
    #  vm.up
    #else
    #  vm.start
    #end

    response :ok
  end

  def stop(request)
    # already running in vagrant (no work necessary)
    #raise "Vagrant environment (env) not specified" unless request["options"].include?("env")
    #env = Vagrant::Environment.new(:cwd => request["options"]["env"])

    #env.vms[:default].halt
    response :ok
  end

  def status(request)
    #raise "Vagrant environment (env) not specified" unless request["options"].include?("env")
    #env = Vagrant::Environment.new(:cwd => request["options"]["env"])

    response :ok, :state => :running
  end
end
