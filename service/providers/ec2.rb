service_provider :ec2 do
  require 'fog'

  # TODO shared logic (fog connection)

  action :status do |request|
    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["secret_access_key"],
      :aws_access_key_id => request["options"]["access_key_id"],
      # TODO options / region
      :region => request["options"]["region"] || "us-east-1"
    })

    server = connection.servers.get(request["options"]["id"])

    raise "No server with id '#{request["options"]["id"]}'." if server.nil?

    response :ok, server.state
  end
end
