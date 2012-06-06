service_provider :dummy do
  action :ping do |request|
    response :ok, :reply => "go tiger!"
  end

  action :failwhale do |request|
    message = request["options"]["message"]

    raise message
  end
end
