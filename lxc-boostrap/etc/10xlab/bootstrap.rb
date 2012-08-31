require 'tenxlabs/chef/handlers/bootstrap'
require "net/http"
require 'yajl'
require 'uri'

cookbook_path "/var/10xlab/cookbooks"
role_path "/var/10xlab/roles"
data_bag_path "/var/10xlab/data_bags"
file_cache_path "/var/10xlab"

# read configuration
endpoint_uri = URI.parse("http://10.0.3.1:8000/endpoint")
response = Net::HTTP.get_response(endpoint_uri)

if response.code == "200"
	body = Yajl::Parser.parse(response.body)

	report_handlers << TenxLabs::Chef::Handlers::Bootstrap.new(body["endpoint"])
else
	#
	# TODO send external error notification for better external monitoring of failed
	#      VM provisioning
	#
	Chef::Log.error "Unable to retrieve local Microcloud's endpoint"
	Chef::Log.error "status=#{response.code}"
	Chef::Log.error "response=#{response.body}"
end
