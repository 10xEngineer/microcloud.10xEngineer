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
  before_filter :validate_vm, :only => [:bootstrap, :start, :stop, :status, :destroy, 
    :snapshot, :persist, :revert, :delshot, :ps_exec]
  before_filter :setup_ssh

  def create(request)
    template = request["options"]["template"] || nil
    size = request["options"]["size"] || 512
    defer = request["options"]["defer"] || false
    name = request["options"]["name"]
    data = request["options"]["data"] || nil
    authorized_keys = request["options"]["authorized_keys"] 

    raise "Lab Machine name required" unless name and !name.empty?

    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "create"]
    command << "--template #{template}" if template
    command << "--size #{size}MB" if size != 0
    command << "--hostname #{name}"
    command << "--defer" if defer
    command << "--data \"#{data}\"" if data
    command << "--keys \"#{authorized_keys}\"" if authorized_keys

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

  def snapshot(request)
    name = request["options"]["name"]

    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "snapshot"]
    command << "--id #{@uuid}"
    command << "--name #{name}" if name

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

  def persist(request)
    name = request["options"]["name"]

    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "persist"]
    command << "--id #{@uuid}"
    command << "--name #{name}"

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

  def revert(request)
    name = request["options"]["name"]
    raise "Snapshot name required" unless name and !name.empty?

    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "revert"]
    command << "--id #{@uuid}"
    command << "--name #{name}" 

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

  def delshot(request)
    name = request["options"]["name"]
    raise "Snapshot name required" unless name and !name.empty?

    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "delshot"]
    command << "--id #{@uuid}"
    command << "--name #{name}" 

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

  # TODO refactor into delshot to handle both instant/persistant snapshots
  def delpshot(request)
    name = request["options"]["snapshot_id"]
    raise "Snapshot id required" unless name and !name.empty?

    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "delpshot"]
    command << "--snapshot #{name}" 

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

  def ps_exec(request)
    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "ps"]
    command << "--id #{@uuid}"

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

  # --- original code

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
    command = ["/usr/bin/sudo", "/usr/local/bin/lab-vm", "-j", "destroy"]
    command << "--id #{@uuid}"

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
      #@ssh_options[:keys] = [@config["ssh_key"]] if @config["ssh_key"]
  end

  def validate_vm(request)
    raise "No VM ID provided." unless request["options"].include?("uuid")

    @uuid = request["options"]["uuid"].strip
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
