#!/usr/bin/env ruby
require 'winrm'

endpoint = "http://ec2-176-34-68-80.eu-west-1.compute.amazonaws.com:5985/wsman"
# TODO basic authentication to prevent HTTP auth errors (invalid savon version)
winrm = WinRM::WinRMWebService.new(
                          endpoint, 
                          :plaintext, 
                          :user => "administrator",
                          :pass => "heslo123", 
                          :basic_auth_only => true)
winrm.cmd('ipconfig /all') do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end
