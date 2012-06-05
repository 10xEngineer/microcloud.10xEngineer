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
    env = Vagrant::Environment.new(:cwd => "/Users/radim/Projects/10xeng/microcloud.10xEngineer/a_vagrant_machine")

    response :ok, :state => env.vms[:default].state
  end
end
