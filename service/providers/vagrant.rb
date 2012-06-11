service_provider :vagrant do
  require 'vagrant'

  # TODO logic for options validation
  # TODO better flow control (possibly exception based)
  # TODO support for multi-VM setups

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
    env = Vagrant::Environment.new(:cwd => request["options"]["env"])

    response :ok, :state => env.vms[:default].state
  end
end
