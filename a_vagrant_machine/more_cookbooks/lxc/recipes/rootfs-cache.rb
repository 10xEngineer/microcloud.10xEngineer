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

  # TODO refactor into helper method (default val, different separator)
  if template["components"].kind_of? Array
    _components = template["components"].join(',')
  else
    raise "Invalid components type (should be Array)"
  end

  if template["packages"].kind_of? Array
    _packages = template["packages"].join(',')
  else
    raise "Invalid packages definition (should be array)"
  end

  # TODO better write_sourceslist
  # TODO from lxc-create
  script "finalize" do
    interpreter "bash"
    user "root"
    cwd "/"
    code <<-EOH
    chroot "#{rootfs_cache}" apt-get update
    chroot "#{rootfs_cache}" apt-get dist-upgrade -y
    EOH

    action :nothing
  end

  execute "debootstrap" do
    # TODO hardcoded amd64 (arch not in ohai data?)
    command "debootstrap --verbose --components=#{_components} --arch=#{node["lxc"]["arch"]} --include=#{_packages} #{node["lxc"]["release"]} #{rootfs_cache}"
    action :nothing

    notifies :run, "script[finalize]", :immediately
  end

  # TODO run apt-get update
  #
  # chmod +x "$1/partial-${arch}"/usr/sbin/policy-rc.d
  #
  # lxc-unshare -s MOUNT -- chroot "$1/partial-${arch}" apt-get dist-upgrade -y
  #
  # rm -f "$1/partial-${arch}"/usr/sbin/policy-rc.d
  #
  #

  directory rootfs_cache do
    owner "root"
    owner "root"
    mode "0775"

    notifies :run, "execute[debootstrap]", :immediately
  end
  
end
