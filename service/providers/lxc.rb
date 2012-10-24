require 'utils/ssh'

class LxcService < Provider
  # container data
  # 
  # id (hash)
  # state (stored outside)
  # type
  # server/pool reference
  # descriptor (disk size, cgroups, firewall, etc). might come from course-lab-descriptor

  before_filter :validate_hostname
  before_filter :validate_vm, :only => [:bootstrap, :start, :stop, :status, :destroy]
  before_filter :setup_ssh

  def create(request)
    template = request["options"]["template"] || nil
    size = request["options"]["size"] || 512
    defer = request["options"]["defer"] || false
    name = request["options"]["name"]

    raise "Lab Machine name required" unless name and !name.empty?

    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "create"]
    command << "--template #{template}" if template
    command << "--size #{size}MB" if size != 0
    command << "--hostname #{name}"
    command << "--defer" if defer

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      error = json_message(e.message)
      error[:source] = "lab-vm"

      response :fail, error
    end    
  end

  # ---- original code

  # ssh stub
  # 
  # TODO SSH Key needs to be loaded to agent!
  # locate machine

  def prepare(request)
    template = request["options"]["template"] || nil
    pool = request["options"]["pool"] || nil
    size = request["options"]["size"].to_i || 0

    # TODO better protection from hostname fixing
    # TODO where to get vgname from?

    command = ["/usr/bin/sudo", "/usr/local/bin/10xeng-vm", "-j", "prepare"]
    command << "--template #{template}" if template
    command << "--vgname #{@vgname}" if @vgname
    command << "--pool #{pool}" if pool
    command << "--size #{size}MB" if size != 0

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      error = json_message(e.message)
      error[:source] = "10xeng-vm"

      response :fail, error
    end
  end

  def bootstrap(request)
    # updated logic (10xEngineer -> 10xLabs switch) the bootstrap is effectivly lcx-start
    #
    # 1. VMs are already prepared
    # 2. Start finishes the bootstrap cycle
    # 3. Initial bootstrap (think knife bootstrap) is facilitated as part of the first boot
    # 4. Sends external notification to MC/TE

    command = ["/usr/bin/sudo", "/usr/local/bin/10xeng-vm", "-j", "start"]
    command << "--id #{@id}"

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      error = json_message(e.message)
      error[:source] = "10xeng-vm"

      response :fail, error
    end
  end

  def stop(request)
    command = ["/usr/bin/sudo", "/usr/local/bin/10xeng-vm", "-j", "stop"]
    command << "--id #{@id}"

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      error = json_message(e.message)
      error[:source] = "10xeng-vm"

      response :fail, error
    end
  end

  def status(request)
    command = ["/usr/bin/sudo", "/usr/local/bin/10xeng-vm", "-j", "info"]
    command << "--id #{@id}"

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      error = json_message(e.message)
      error[:source] = "10xeng-vm"

      response :fail, error      
    end
  end

  def destroy(request)
    command = ["/usr/bin/sudo", "/usr/local/bin/10xeng-vm", "-j", "destroy"]
    command << "--id #{@id}"

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      error = json_message(e.message)
      error[:source] = "10xeng-vm"

      response :fail, error
    end
  end

  private

  def setup_ssh(request)
      @ssh_options = {
        :port => @port
      }

      # TODO using key file directly, switch to ssh-agent later
      @ssh_options[:keys] = [@config["ssh_key"]] if @config["ssh_key"]
  end

  def validate_vm(request)
    raise "No VM ID provided." unless request["options"].include?("id")

    @id = request["options"]["id"].strip
  end

  def validate_hostname(request)
    raise "No server specification provided." unless request["options"].include?("server")

    @hostname = request["options"]["server"].strip
    @port = 22
    @vgname = nil

    # TODO how to handle specific settings
    if @hostname == "tenxeng-precise32" 
      @port = 2222
      @vgname = "tenxeng-precise32"
    end

  end

  # TODO whole migration/persistence commands will follow
end
