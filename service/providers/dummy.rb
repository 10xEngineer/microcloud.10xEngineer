service_provider :dummy do
  action :ping do |request|
    puts "ping pong, with honk kong king kong"

    response :ok, :reply => "go tiger!"
  end
end
