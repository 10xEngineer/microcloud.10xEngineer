# utils/ssh.rb

require 'net/ssh'

def ssh_exec(user, hostname, command, options = {:port => 22}) 
  output = ''

  options[:port] = 22 unless options[:port]

  unless options[:keys]
    puts "WARNING: no ssh-key provided"
  end

  Net::SSH.start(hostname, user, options) do |ssh|
    stdout_data = ""
    stderr_data = ""
    exit_code = nil
    exit_signal = nil
    ssh.open_channel do |channel|
      channel.exec(command) do |ch, success|
        unless success
          abort "FAILED: couldn't execute command (ssh.channel.exec)"
        end
        channel.on_data do |ch,data|
          stdout_data+=data
        end

        channel.on_extended_data do |ch,type,data|
          stderr_data+=data
        end

        channel.on_request("exit-status") do |ch,data|
          exit_code = data.read_long
        end

        channel.on_request("exit-signal") do |ch, data|
          exit_signal = data.read_long
        end
      end
    end
    ssh.loop

    raise stdout_data if exit_code != 0

    output = stdout_data
  end

  output
end

def json_message(message, name = :reason)
  begin
    return Yajl::Parser.parse(message)
  rescue
    return {name => message}
  end
end
