require 'utils/virtualbox'
require 'vagrant'

class VagrantService < Provider
  # Change original spec. For development purposes it should be already running 
  # in VirtualBox. 
  #
  # TODO support for multi-VM setups

  def start(request)
    if  TenxEngineer::VirtualBox.detect?
      return response :ok, :id => :default
    end

    #raise "Vagrant environment (env) not specified" unless request["options"].include?("env")

    #env = Vagrant::Environment.new(:cwd => request["options"]["env"])
    #vm = env.vms[:default]

    #unless env.vms[:default].created?
    #  vm.up
    #else
    #  vm.start
    #end

    response :ok, :id => :default
  end

  def stop(request)
    if  TenxEngineer::VirtualBox.detect?
      return response :ok, :long_story => "Microcloud seems to be running in VirtualBox. Not really going to shoot myself in the foot"
    end

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
