
# definition
lab = {
  :course => nil,
  :name => 'test-1',
  :token => '33ee44',
  :vm => {
    "webserv" => {
      "type" => "ubuntu", # lxc-template, chef-template, cpu, basic storage, etc.
      "hostname" => "webserver.local",
      "run_list" => ['a1','a2','a3'],
      "attributes => {}
    },
    "dbserv" => {
      "type" => "ubuntu",
      "hostname" => "db.local"
      "run_list" => ['a1','a2','a3'],
      "attributes => {}
    }
  }
}

# instance
lab_inst = {
  :definition => "test-1",
  :id => 'e27ee9f',
  :terminal_server => "https://e27ee9f.test-1.somwhere.10xlabs.com",
  :vms => {
    "webserv" => {
      :id => '052681f0-9831-012f-7f05-0800272cf3a1',
      :ip_addr => '10.0.1.1',
      :state => "running",
    },
    "dbserv" => {
      :id => '0af07d60-9826-012f-6c48-0800272cf3a1',
      :ip_addr => '10.0.1.2',
      :state => "running"
    }
  }
}

#{'id': '052681f0-9831-012f-7f05-0800272cf3a1', 'alias': 'webserv', 'ip_addr': '10.0.3.229'},
