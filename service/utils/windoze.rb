# utils/windoze.rb
require 'winrm'
require 'uri'

def winrm_exec(user, password, hostname, command, options = {})
  # TODO http only
  options[:port] = 5985 unless options[:port]

  output = nil

  endpoint = URI::HTTP.build({
    :host => hostname,
    :port => options[:port],
    :path => "/wsman"
  })

  winrm = WinRM::WinRMWebService.new(
                      endpoint,
                      :plaintext,
                      :user => user,
                      :pass => password,
                      :basic_auth_only => true)

  winrm.cmd(command) do |stdout, stderr|
    if stderr
      raise stderr.split("\r\n").first
    end

    output = stdout.split("\r\n")
  end

  output
end
