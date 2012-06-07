# utils/ssh.rb

require 'net/ssh'

def ssh_exec(user, hostname, command, options = {:port => 22}) 
  output = ''

  Net::SSH.start(hostname, user, :port => options[:port] || 22) do |ssh|
    output = ssh.exec!(command)
  end

  output
end