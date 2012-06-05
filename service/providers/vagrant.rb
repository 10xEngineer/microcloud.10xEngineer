service_provider :vagrant do
  require 'vagrant'

  action :start do |request|
    env = Vagrant::Environment.new

    # FIXME implement vagrant logic

    puts "vagrant::start"
  end

  action :stop do |request|
    # FIXME implement vagrant logic

    puts "vagrant::stop"
  end
end
