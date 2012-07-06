require 'fog'
require 'erb'
require 'yajl'

class BrightboxService < Provider
  def start(request)
    connection = Fog::Compute.new({
      :provider => 'Brightbox',
      :brightbox_api_url => request["options"]["data"]["brightbox_api_url"],
      :brightbox_auth_url => request["options"]["data"]["brightbox_auth_url"],
      :brightbox_client_id => request["options"]["data"]["brightbox_client_id"],
      :brightbox_secret => request["options"]["data"]["brightbox_secret"],
      :persistent => "true"
      })

    dist_file = File.join(File.dirname(__FILE__), "../dist/10xlabs-bb-#{@hostnode_handler}.erb")

    if File.exists? dist_file
      template = ERB.new File.read(dist_file)
      user_data = template.result(binding)
    else
      user_data = nil
    end

    server = connection.servers.create({
      :image_id => request["options"]["data"]["image_id"],
      :flavor_id => request["options"]["data"]["flavor_id"]
      })

    response :ok, :id => server.id, :hostname => nil
  end

  def stop(request)
  end
end
