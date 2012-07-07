#!/usr/bin/env ruby
require 'winrm'

endpoint = "http://109.107.37.118:5985/wsman"
# TODO basic authentication to prevent HTTP auth errors (invalid savon version)
winrm = WinRM::WinRMWebService.new(
                          endpoint, 
                          :plaintext, 
                          :user => "administrator",
                          :pass => "C9fcx2vTZAzeQt", 
                          :basic_auth_only => true)
winrm.cmd('ipconfig /all') do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end
