require 'fog'
require 'erb'

class Ec2Service < Provider

  BINARY_DIST = {
    :bucket => 'ops-images',
    :file => 'hostnode-dist.tar.gz'
  }

  def start(request)
    connection = Fog::Compute.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["data"]["secret_access_key"],
      :aws_access_key_id => request["options"]["data"]["access_key_id"],
      :region => request["options"]["data"]["region"] || "us-east-1"
    })

    # TODO prepare temporary download URL (valid for 1 hour)
    #      ? how to maintain multiple ec2 accounts and URL signature (most likely single URL?)
    # TODO use current AWS account to sign it
    # TODO and using ERB generate user_data
   
    # sign URL
    s3 = Fog::Storage.new({
      :provider => 'AWS',
      :aws_secret_access_key => request["options"]["data"]["secret_access_key"],
      :aws_access_key_id => request["options"]["data"]["access_key_id"],
      :region => request["options"]["data"]["region"] || "us-east-1"
    })

    # TODO re-use signed URLs (general quite slow)
    # TODO bucket needs to be in same region (otherwise 301)
    #      might be easier to get single CF URL
    bucket_name = "tenxops-#{request["options"]["data"]["region"]}"

    bucket = s3.directories.get(bucket_name)
    target_file = bucket.files.get(BINARY_DIST[:file])

    expiration = Time.now.utc + 60*15
    download_url = target_file.url(expiration)

    template = ERB.new(File.read(File.join(File.dirname(__FILE__), "../dist/10xeng-dist.sh.erb")))
    user_data = template.result(binding)

    # TODO availability zone
    server = connection.servers.create(:key_name => request["options"]["data"]["key"],
                                       :image_id => request["options"]["data"]["ami"],
                                       :flavor_id => request["options"]["data"]["type"],
                                       :user_data => user_data )

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
