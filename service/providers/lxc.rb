require 'utils/ssh'

class LxcService < Provider
  # container data
  # 
  # id (hash)
  # state (stored outside)
  # type
  # server/pool reference
  # descriptor (disk size, cgroups, firewall, etc). might come from course-lab-descriptor
  

  # ssh stub
  # 
  # TODO SSH Key needs to be loaded to agent!
  # locate machine

  def prepare(request)
    raise "No server specification provided." unless request["options"].include?("server")

    hostname = request["options"]["server"].strip
    template = request["options"]["template"] || nil
    port = 22
    vgname = nil

    # TODO better protection from hostname fixing
    # TODO will hurt later (need better way how to read vagrant configuration)
    if hostname == "vagrant.local" 
      hostname = "localhost"
      port = 2222
      vgname = "precise32-mc"
    end

    command = ["/usr/bin/sudo", "/opt/ruby/bin/10xeng-vm", "-j", "prepare"]
    command << "--template #{template}" if template
    command << "--vgname #{vgname}" if vgname

    begin
      res = ssh_exec('mchammer', hostname, command.join(' '), {:port => port})

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      response :fail, json_message(e.message)
    end
  end

  def allocate(request)
    # allocate prepared container 
    # arguments: id, course_template (how to finish the provisioning)
  end

  def start(request)
  end

  def stop(request)
  end

  def status(request)
  end

  # TODO whole migration/persistence commands will follow
end
