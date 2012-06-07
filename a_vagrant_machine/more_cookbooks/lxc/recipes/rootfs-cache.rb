# cookbook: lxc
# recipe: rootfs-cache
#
# Maintain local rootfs cache

release_dir = File.join(node["lxc"]["cache"], node["lxc"]["release"]) 
rootfs_cache = File.join(release_dir, "rootfs-cache") 

package "debootstrap" do
  action :install
end

directory node["lxc"]["cache"] do
  owner "root"
  group "root"
  mode "0775"

  action :create
end

directory release_dir do
  owner "root"
  group "root"
  mode "0775"
end

# TODO create deboostrap resource (with options to flush existing cache, etc.)
node["lxc"]["templates"].each do |templ_name|
  template = node["lxc-template"][templ_name]

  # TODO refactor into helper method
  if template["components"].kind_of? Array
    _components = template["components"].join(',')
  elsif template["components"].kind_of? String
    _components = template["components"]
  else
    _components = "main,universe"
  end

  if template["packages"].kind_of? Array
    _packages = template["packages"].join(',')
  else
    _packages = template["packages"]
  end

  execute "debootstrap" do
    # TODO hardcoded amd64 (arch not in ohai data?)
    command "debootstrap --verbose --components=#{_components} --arch=amd64 --include=#{_packages} #{node["lxc"]["release"]} #{rootfs_cache}"
    action :nothing
  end

  directory rootfs_cache do
    owner "root"
    owner "root"
    mode "0775"

    notifies :run, "execute[debootstrap]", :immediately
  end
  
end
