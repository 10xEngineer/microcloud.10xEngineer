# cookbook mc-node
# recipe default

admins = data_bag('admins')
admins.each do |uid|
  u = data_bag_item('admins', uid)

  home_dir = "/home/#{u["id"]}"

  user u["id"] do
    comment u["full_name"]
    uid u["uid"]
    gid u["groups"].first
    home home_dir
    shell u["shell"]

    supports :manage_home => false
  end

  directory home_dir do
    owner u["id"]
    group u["groups"].first
    mode "0775"

    action :create
  end

  directory "#{home_dir}/.ssh" do
    owner u["id"]
    group u["groups"].first
    mode "0700"

    action :create
  end

  template "/home/mchammer/.ssh/authorized_keys" do
    owner u["id"]
    group u["groups"].first
    mode "0600"

    variables :key => u["ssh_key"]

    action :create
  end
end

directory "/var/lib/10eng/" do
  owner "mchammer"
  group "users"

  recursive true
  mode "0775"

  action :create
end