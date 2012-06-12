# obviously this is using the "alternate" ISO, not the "server" ISO, but that
# is only because it hasn't been released yet.
Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '512',
  :disk_size => '20480',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id => 'Ubuntu',
  :iso_file => "ubuntu-12.04-server-i386.iso",
  :iso_src => "http://releases.ubuntu.com/12.04/ubuntu-12.04-server-i386.iso",
  :iso_md5 => '32184a83c8b5e6031e1264e5c499bc03',
  :iso_download_timeout => "1000",
  :boot_wait => "4",
  :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
    'hostname=%NAME% ',
    'fb=false debconf/frontend=noninteractive ',
    'keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter>'
],
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  # TODO merge with ami_builder postinstall.sh to reduce duplication
  :postinstall_files => [ "postinstall.sh"],
  :postinstall_timeout => "10000"
})
