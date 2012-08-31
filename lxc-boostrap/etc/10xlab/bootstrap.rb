require 'tenxlabs/chef/handlers/bootstrap'

cookbook_path "/var/10xlab/cookbooks"
role_path "/var/10xlab/roles"
data_bag_path "/var/10xlab/data_bags"
file_cache_path "/var/10xlab"

# FIXME hardcoded endpoint
report_handlers << TenxLabs::Chef::Handlers::Bootstrap.new("http://bunny.laststation.net:8080")
