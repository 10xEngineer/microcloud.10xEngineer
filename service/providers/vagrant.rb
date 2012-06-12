require 'utils/virtualbox'

service_provider :vagrant do
  require 'vagrant'

  # TODO logic for options validation
  # TODO support for multi-VM setups

  # TODO it should already be running in vagrant!!
  # TODO add multi-vm support
  action :start do |request|
    raise "Vagrant environment (env) not specified" unless request["options"].include?("env")

    env = Vagrant::Environment.new(:cwd => request["options"]["env"])
    vm = env.vms[:default]

    unless env.vms[:default].created?
      vm.up
    else
      vm.start
    end

    response :ok
  end

  action :stop do |request|
    raise "Vagrant environment (env) not specified" unless request["options"].include?("env")
    env = Vagrant::Environment.new(:cwd => request["options"]["env"])

    env.vms[:default].halt
    response :ok
  end

  action :status do |request|
    raise "Vagrant environment (env) not specified" unless request["options"].include?("env")

    return :ok

    env = Vagrant::Environment.new(:cwd => request["options"]["env"])

    puts "--> #{TenxEngineer::VirtualBox.detect?}"

    response :ok, :state => env.vms[:default].state
  end
end
