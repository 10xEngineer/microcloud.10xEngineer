require 'uuid'
require 'model/vm'

class LoopService < Provider
  before_filter :validate_hostname

  def prepare(request)
    vm = Vm.where(hostnode: @hostname).first
    if vm
      # loopback allows only a single VM per hostnode
      return response :fail, {:reason => "VM already exists for hostnode=#{@hostname} type=loop"}
    end

    uuid = UUID.new
    # TODO hardcoded default descriptor
    #      need to have way how to connect to managed hostnode
    #      provide same mechanism (say as ssh in LXC, winrm for windows?):w
    descriptor = {
      :fs => {:size => "10000GB"}
    }

    vm = Vm.new(uuid: uuid.generate, hostnode: @hostname, descriptor: descriptor)
    vm.save

    response :ok, vm.as_document
  end

  def allocate(request)
    # TODO implement
    response :ok
  end

  def start(request)
    # already running (one-to-one to hostnode)
    response :ok
  end

  def stop(request)
    # doesn't make any sense (vm is mapped one-to-one to hostnode)
    response :ok
  end

  def status(request)
    # TODO implement
    response :fail, {:reason => "status not yet implemented"}
  end

private

  # TODO refactor (shared with lxc and probably other services)
  def validate_hostname(request)
    raise "No server specification provided." unless request["options"].include?("server")

    @hostname = request["options"]["server"].strip
    @port = 5985
  end

end
