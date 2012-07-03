#!/usr/bin/env ruby
require 'winrm'

endpoint = "http://10.0.1.4:5985/wsman"
# TODO basic authentication to prevent HTTP auth errors (invalid savon version)
winrm = WinRM::WinRMWebService.new(
                          endpoint, 
                          :plaintext, 
                          :user => "administrator",
                          :pass => "vagrant", 
                          :basic_auth_only => true)
winrm.cmd('ipconfig /all') do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end
