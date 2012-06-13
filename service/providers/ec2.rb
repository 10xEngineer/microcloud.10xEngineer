require 'fog'

class Ec2Service < Provider

  def start(request)
    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["secret_access_key"],
      :aws_access_key_id => request["options"]["access_key_id"],
      :region => request["options"]["region"] || "us-east-1"
    })

    # TODO availability zone
    server = connection.servers.create(:key_name => request["options"]["key"],
                                          :image_id => request["options"]["ami"],
                                          :flavor_id => request["options"]["type"],
                                          :user_data => File.read(File.join(File.dirname(__FILE__), "../dist/10xeng.sh")))

    # TODO hostname is nil (might be good idea to create own hostname/DNS provisioning)
    response :ok, :id => server.id, :hostname => server.dns_name
  end
  
  def stop(request)
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

  def status(request)
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
