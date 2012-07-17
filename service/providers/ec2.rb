require 'fog'
require 'erb'
require 'yajl'

class Ec2Service < Provider

  BINARY_DIST = {
    :bucket => 'ops-images',
    :file => 'hostnode-dist.tar.gz'
  }

  before_filter :user_data, :only => [:start]

  def start(request)
    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["data"]["secret_access_key"],
      :aws_access_key_id => request["options"]["data"]["access_key_id"],
      :region => request["options"]["data"]["region"] || "us-east-1"
    })

    provider_name = request["options"]["name"]

    # hostnode specific ec2 templates
    dist_file = File.join(File.dirname(__FILE__), "../dist/10xlabs-ec2-#{@hostnode_handler}.erb")

    if File.exists? dist_file
      template = ERB.new File.read(dist_file)
      user_data = template.result(binding)
    else
      user_data = nil
    end

    # TODO availability zone
    server = connection.servers.create(:key_name => request["options"]["data"]["key"],
                                       :image_id => request["options"]["data"]["ami"],
                                       :flavor_id => request["options"]["data"]["type"],
                                       :security_group_ids => request["options"]["data"]["security_group"],
                                       :user_data => user_data)

    # tag newly created server
    connection.tags.create :key => "source", :value => "10xlabs", :resource_id => server.id
    connection.tags.create :key => "provider", :value => provider_name, :resource_id => server.id

    # TODO hostname is nil (might be good idea to create own hostname/DNS provisioning)
    response :ok, :id => server.id, :hostname => server.dns_name
  end

  def stop(request)
    raise "No server id provided." unless request["options"].include?("server_id")

    # TODO really ugly to pass such a complex structures - options.provider.data 
    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["provider"]["data"]["secret_access_key"],
      :aws_access_key_id => request["options"]["provider"]["data"]["access_key_id"],
      :region => request["options"]["provider"]["data"]["region"] || "us-east-1"
    })

    server = connection.servers.get(request["options"]["server_id"])

    server.destroy

    response :ok
  end

  def status(request)
    raise "No server id provided." unless request["options"].include?("server_id")

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

  private

  # 
  # prepares per-hostnode-type user data
  def user_data(request)
    @hostnode_handler = request["options"]["handler"]

    send_ext("#{@hostnode_handler}_user_data", request)
  end

  def lxc_user_data(request)
    s3 = Fog::Storage.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["data"]["secret_access_key"],
      :aws_access_key_id => request["options"]["data"]["access_key_id"],
      :region => request["options"]["data"]["region"] || "us-east-1"
    })

    # TODO re-use signed URLs (general quite slow)
    # TODO bucket needs to be in same region (otherwise 301)
    #      might be easier to get single CF URL
    bucket_name = "tenxlabs-#{request["options"]["data"]["region"]}"

    bucket = s3.directories.get(bucket_name)
    target_file = bucket.files.get(BINARY_DIST[:file])

    expiration = Time.now.utc + 60*15
    @download_url = target_file.url(expiration)
  end

  def loop_user_data
    # TODO add authorization details
    instance_data = {
      :endpoint => @config["hostnode"]["endpoint"]
    }

    @loop_user_data = Yajl::Encoder.encode(instance_data)
  end
end
