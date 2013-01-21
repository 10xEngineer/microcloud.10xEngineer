require 'fog'
require 'erb'
require 'yajl'
require 'rbvmomi'

class VSphereService < Provider

  BINARY_DIST = {
    :bucket => 'ops-images',
    :file => 'hostnode-dist.tar.gz'
  }

  before_filter :user_data, :only => [:start]

# Could consider starting by simply cloning a vm template which would be the most common use case
#  new_vm=f.vm_clone('instance_uuid' => '501b12d9-18c1-e123-ceff-97292ef15bdf', 'name' => 'clonedvm'){"vm_ref"=>"vm-14", "task_ref"=>"task-5"}

  def start(request)
    connection = Fog::Compute.new({
      :provider => 'vsphere',
      :vsphere_username => request["options"]["data"]["vsphere_username"],
      :vsphere_password => request["options"]["data"]["vsphere_password"],
      :vsphere_server => request["options"]["data"]["vsphere_server"],
      :vsphere_expected_pubkey_hash => request["options"]["data"]["vsphere_expected_pubkey_hash"] || "74e6f3f9a9d50be352aa0fabcdc1df9977016af38da538cf76b3ba56a6363d11"      
    })

    provider_name = request["options"]["name"]

    # hostnode specific vsphere templates
    dist_file = File.join(File.dirname(__FILE__), "../dist/10xlabs-vsphere-#{@hostnode_handler}.erb")

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
    connection.tags.create :key => "role", :value => "hostnode", :resource_id => server.id

    # TODO hostname is nil (might be good idea to create own hostname/DNS provisioning)
    response :ok, :id => server.id, :hostname => server.dns_name
  end

  def stop(request)
    raise "No server id provided." unless request["options"].include?("server_id")

    # TODO really ugly to pass such a complex structures - options.provider.data 
    connection = Fog::Compute.new({
      :provider => 'vsphere',
      :vsphere_username => request["options"]["data"]["vsphere_username"],
      :vsphere_password => request["options"]["data"]["vsphere_password"],
      :vsphere_server => request["options"]["data"]["vsphere_server"],
      :vsphere_expected_pubkey_hash => request["options"]["data"]["vsphere_expected_pubkey_hash"] || "74e6f3f9a9d50be352aa0fabcdc1df9977016af38da538cf76b3ba56a6363d11"      
    })

    server = connection.servers.get(request["options"]["server_id"])

    server.destroy

    response :ok
  end

  def status(request)
    raise "No server id provided." unless request["options"].include?("server_id")

    connection = Fog::Compute.new({
      :provider => 'vsphere',
      :vsphere_username => request["options"]["data"]["vsphere_username"],
      :vsphere_password => request["options"]["data"]["vsphere_password"],
      :vsphere_server => request["options"]["data"]["vsphere_server"],
      :vsphere_expected_pubkey_hash => request["options"]["data"]["vsphere_expected_pubkey_hash"] || "74e6f3f9a9d50be352aa0fabcdc1df9977016af38da538cf76b3ba56a6363d11"      
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
      :provider => 'vsphere',
      :vsphere_username => request["options"]["data"]["vsphere_username"],
      :vsphere_password => request["options"]["data"]["vsphere_password"],
      :vsphere_server => request["options"]["data"]["vsphere_server"],
      :vsphere_expected_pubkey_hash => request["options"]["data"]["vsphere_expected_pubkey_hash"] || "74e6f3f9a9d50be352aa0fabcdc1df9977016af38da538cf76b3ba56a6363d11"      
    })

    # TODO re-use signed URLs (general quite slow)
    # TODO bucket needs to be in same region (otherwise 301)
    #      might be easier to get single CF URL
    bucket_name = "tenxlabs-#{request["options"]["data"]["region"]}"

    bucket = s3.directories.get(bucket_name)
    target_file = bucket.files.get(BINARY_DIST[:file])

    expiration = Time.now.utc + 60*15
    @download_url = target_file.url(expiration)

    # TODO endpoint_url can be populated to user-data script
    @endpoint_url = @config["endpoint"]
  end

  def loop_user_data
    # TODO add authorization details
    instance_data = {
      :endpoint => @config["endpoint"]
    }

    @loop_user_data = Yajl::Encoder.encode(instance_data)
  end
end
