service_provider :vagrant do
  require 'vagrant'

  # TODO logic for options validation
  # TODO better flow control (possibly exception based)
  # TODO support for multi-VM setups

  action :start do |request|
    if request["options"].include?("env")
      env = Vagrant::Environment.new(:cwd => request["options"]["env"])

      env.vms[:default].start
    else
      response :fail, :reason => "Vagrant environment (env) not specified."
    end
  end

  action :stop do |request|
    if request["options"].include?("env")
      env = Vagrant::Environment.new(:cwd => request["options"]["env"])

      env.vms[:default].halt
    else
      response :fail, :reason => "Vagrant environment (env) not specified."
    end
  end

  action :status do |request|
    if request["options"].include?("env")
      env = Vagrant::Environment.new(:cwd => request["options"]["env"])

      response :ok, :state => env.vms[:default].state
    else
      response :fail, :reason => "Vagrant environment (env) not specified."
    end
  end
end
