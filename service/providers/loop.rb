require 'uuid'
require 'model/vm'
require 'utils/windoze'

# TODO how to specify different service handlers? i.e. right now it's winrm specific
#      but might be other provider in future
# TODO different handler might provider even different toolchain expections
#      i.e. winrm with custom 10xlabs tools and direct commands
# TODO right now it does execute local commands
class LoopService < Provider
  before_filter :validate_hostname

  def prepare(request)
    vm_type = "win2008r2"

    vm = Vm.where(hostnode: @hostname).first
    if vm
      # loopback allows only a single VM per hostnode
      return response :fail, {:reason => "VM already exists for hostnode=#{@hostname} type=loop"}
    end

    # TODO Windows VM has to be single volume (at least for now)
    #      Amazon EC2 deployment is EBS based anyway, but might user ephemeral storage
    #      later.
    command = ['fsutil','volume','diskfree','C:']

    begin
      # TODO create different user and use real-life authentication
      res = winrm_exec('administrator', 'vagrant', @hostname, command.join(' '))

      # TODO this is really just a demonstration of winrm provider
      total_size = (res[1].split(':').last.to_f / (1024*1024*1024)).round

      descriptor = {
      :fs => {:size => "#{total_size}GB"}
      }
    rescue Exception => e
      return response :fail, {:reason => "loop: #{e.message}"}
    end

    uuid = UUID.new
    # TODO hardcoded default descriptor
    #      need to have way how to connect to managed hostnode
    #      provide same mechanism (say as ssh in LXC, winrm for windows?)
    
    vm = Vm.new(uuid: uuid.generate, hostnode: @hostname, type: vm_type, descriptor: descriptor)
    vm.save

    response :ok, vm.as_document
  end

  def allocate(request)
    # TODO implement (actual chef/provisioning run)
    response :ok

    notify :vm, request["options"]["id"], :allocate, {}
  end

  def start(request)
    response :ok

    # FIXME vm_descriptor to return ip_addr

    notify :vm, request["options"]["id"], :start, vm_descriptor
  end

  def stop(request)
    response :ok

      # FIXME vm_descriptor

    notify :vm, require["options"]["id"], :stop, vm_descriptor
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
