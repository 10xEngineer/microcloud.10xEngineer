service_provider :ec2 do
  require 'fog'

  # TODO shared logic (fog connection), rails filter style

  action :start do |request|
    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["secret_access_key"],
      :aws_access_key_id => request["options"]["access_key_id"],
      :region => request["options"]["region"] || "us-east-1"
    })

    # TODO availability zone
    server = connection.servers.create(:key_name => request["options"]["key"],
                                          :image_id => request["options"]["ami"],
                                          :flavor_id => request["options"]["type"])

    # TODO use bootstrap instead (and run chef provisioning)

    response :ok, :id => server.id
  end
  
  action :stop do |request|
    raise "No server id provided." unless request["options"].include?("id")

    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["secret_access_key"],
      :aws_access_key_id => request["options"]["access_key_id"],
      :region => request["options"]["region"] || "us-east-1"
    })

    server = connection.servers.get(request["options"]["id"])

    server.destroy

    response :ok
  end

  action :status do |request|
    raise "No server id provided." unless request["options"].include?("id")

    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["secret_access_key"],
      :aws_access_key_id => request["options"]["access_key_id"],
      :region => request["options"]["region"] || "us-east-1"
    })

    server = connection.servers.get(request["options"]["id"])

    raise "No server with id '#{request["options"]["id"]}'." if server.nil?

    response :ok, server.state
  end
end
