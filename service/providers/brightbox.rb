require 'fog'
require 'erb'
require 'yajl'
require 'base64'

class BrightboxService < Provider
  before_filter :user_data, :only => [:start]

  # TODO shared logic with ec2 service (linux hostnode provisioning)
  #      might be based on the same subclass
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

    server = connection.servers.create(
      :image_id => request["options"]["data"]["image_id"],
      :flavor_id => request["options"]["data"]["flavor_id"],
      :user_data => Base64.encode64(user_data)
      )

    response :ok, :id => server.id, :hostname => nil

    server.wait_for { ready? }

    # allocate and assign cloud ip
    # from knife-brightbox
    # https://github.com/rubiojr/knife-brightbox/blob/master/lib/chef/knife/brightbox_server_create.rb
    ip = connection.create_cloud_ip
    cip = connection.cloud_ips.get ip['id']
    cip.map server

    # TODO to notify or not notify
    #notify :node, server.id, :ip_allocated
  end

  def stop(request)
    raise "No server id provided." unless request["options"].include?("server_id")

    connection = Fog::Compute.new({
      :provider => 'Brightbox',
      :brightbox_api_url => request["options"]["provider"]["data"]["brightbox_api_url"],
      :brightbox_auth_url => request["options"]["provider"]["data"]["brightbox_auth_url"],
      :brightbox_client_id => request["options"]["provider"]["data"]["brightbox_client_id"],
      :brightbox_secret => request["options"]["provider"]["data"]["brightbox_secret"],
      :persistent => "true"
      })

    server = connection.servers.get request["options"]["server_id"]

    raise "No server with id '#{request["options"]["id"]}'." if server.nil?

    # TODO how to handle pernament IPs (ie. which are part of definition)
    server.cloud_ips.each do |ip_def|
      ip = connection.cloud_ips.get ip_def['id']

      ip.unmap if ip.mapped?
      3.times do
        break unless ip.mapped?
        sleep 1
        ip.reload
      end

      ip.destroy
    end

    server.destroy

    response :ok
  end

private
  def user_data(request)
    @hostnode_handler = request["options"]["handler"]

    send_ext("#{@hostnode_handler}_user_data", request)
  end

  def loop_user_data
    # TODO add authorization details
    instance_data = {
      :endpoint => @config["hostnode"]["endpoint"]
    }

    @loop_user_data = Yajl::Encoder.encode(instance_data)
  end
end
