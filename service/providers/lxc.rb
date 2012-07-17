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
  before_filter :validate_vm, :only => [:allocate, :start, :stop, :status, :destroy]
  before_filter :setup_ssh

  # ssh stub
  # 
  # TODO SSH Key needs to be loaded to agent!
  # locate machine

  def prepare(request)
    template = request["options"]["template"] || nil
    pool = request["options"]["pool"] || nil

    # TODO better protection from hostname fixing
    # TODO where to get vgname from?

    command = ["/usr/bin/sudo", "/usr/local/bin/10xeng-vm", "-j", "prepare"]
    command << "--template #{template}" if template
    command << "--vgname #{@vgname}" if @vgname
    command << "--pool #{pool}" if pool

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      response :fail, "10xeng-vm: #{json_message(e.message)}"
    end
  end

  def allocate(request)
    # allocate prepared container 
    # arguments: id, course_template (how to finish the provisioning)

    # TODO allocate vs start
    # TODO unable to run lxc-execute to finish provisioning
    # TODO lxc-start 
    #
    endpoint = @config["hostnode"]["endpoint"]

    # confirm processing
    response :ok

    # FIXME remove - simulating long running operation
    sleep 3 + (rand 10)

    # TODO build body with basic attributes (id used from resource_id)
    notify :vm, request["options"]["id"], :allocate, {}
  end

  def start(request)
    command = ["/usr/bin/sudo", "/usr/local/bin/10xeng-vm", "-j", "start"]
    command << "--id #{@id}"

    begin
      res = ssh_exec('mchammer', @hostname, command.join(' '), @ssh_options)

      options = Yajl::Parser.parse(res)

      response :ok, options
    rescue Net::SSH::AuthenticationFailed => e
      response :fail, {:reason => "Hostnode authentication failed"}
    rescue Exception => e
      response :fail, "10xeng-vm: #{json_message(e.message)}"
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
      response :fail, "10xeng-vm: #{json_message(e.message)}"
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
      response :fail, "10xeng-vm: #{json_message(e.message)}"
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
      response :fail, "10xeng-vm: #{jjson_message(e.message)}"
    end
  end

  private

  def setup_ssh(request)
      @ssh_options = {
        :port => @port
      }

      # TODO using key file directly, switch to ssh-agent later
      @ssh_options[:keys] = [@config["hostnode"]["ssh_key"]] if @config["hostnode"] && @config["hostnode"]["ssh_key"]
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
