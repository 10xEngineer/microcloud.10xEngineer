service_provider :dummy do
  action :ping do |request|
    puts "ping pong, with honk kong king kong"
  end
end
