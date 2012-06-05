service_provider :vagrant do
  require 'vagrant'

  # TODO pass environment details

  action :start do |request|
    env = Vagrant::Environment.new

    # FIXME implement vagrant logic

    puts "vagrant::start"
  end

  action :stop do |request|
    # FIXME implement vagrant logic

    puts "vagrant::stop"
  end

  action :status do |request|
    puts request.inspect
    if request["options"].include?("env")
      env = Vagrant::Environment.new(:cwd => request["options"]["env"])

      response :ok, :state => env.vms[:default].state
    else
      response :fail, :reason => "Vagrant environment (env) not specified."
    end
  end
end
