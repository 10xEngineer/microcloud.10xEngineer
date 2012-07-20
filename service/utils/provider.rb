require 'yajl'
require 'facets'
require '10xlabs/microcloud'

# TODO before filter support (for shared logic)

class Provider
  attr_accessor :name, :actions

  @@filters = {}

  def initialize(config)
    @actions = {}
    @config = config
    @socket = nil

    @microcloud = nil
  end

  def self.load_service(name, config)
    service = "#{name}_service"
    # TODO needed?
    klass = service.camelcase(:upper)

    service_file = File.join(File.dirname(__FILE__), "../providers/#{name}.rb")
    raise "No service provider found: #{service_file}" unless File.exists?(service_file)

    load service_file

    Object.const_get(klass).new(config)
  end

  def fire(_action, request, socket)
    @socket = socket
    action = _action.to_sym

    # allow only methods defined by the service class
    
    if self.class.instance_methods(false).include?(action.to_sym)
      m = self.method(action)

      begin
        res = nil
        
        filters = evaluate_filters(action)
        filters.each do |f|
          send_ext(f, request, :filter)
        end

        res = send_ext(action, request)

        if res.nil? && @socket
          res = response :ok
        end

        res 
      rescue Exception => e
        puts "error=#{e.message}"
        puts e.backtrace

        return response :fail, :reason => e.message
      ensure
        @socket = nil
      end
    else
      return response :fail, :reason => "Action not defined (#{action})"
    end
  end

  # 
  # provide response to client
  #
  # Use cases
  # 1. return response :ok - to terminate processing and send response
  # 2. response :ok - to send response and continue processing (not output possible after this)
  #
  def response(res = :ok, options = {})
    res = {
      :status => res
    }

    res[:options] = options unless options.empty?

    if @socket
      @socket.send_string Yajl::Encoder.encode(res)
      @socket = nil
    else
      puts "socket not available (possibly duplicate response)"
    end

    res
  end

  def notify(resource, resource_id, action, hash)
    body = Yajl::Encoder.encode(hash)

    microcloud.notify(resource, resource_id, action, hash)
  end
  
  def self.get(name)
    @@providers[name]
  end

  def self.service_name(klass)
    reg = klass.match /(.*)Service$/
    raise "Unknown service class: #{klass}" unless reg

    reg[1]
  end

  def evaluate_filters(action)
    res = []

    @@filters.keys.each do |f|
      unless @@filters[f].include?(:only)
        res << f
      else
        res << f if @@filters[f][:only].include?(action)
      end
    end

    res
  end

  def self.before_filter(method_name, options = {})
    @@filters[method_name] = options
  end

  def Provider::filters
    @@filters
  end

private

  def microcloud
    @microcloud ? @microcloud : TenxLabs::Microcloud.new(@config["hostnode"]["endpoint"])
  end

  def send_ext(action, request, type = :action)
    method = self.method(action)

    if method.parameters.size == 1
      res = self.send(action, request)
    elsif method.parameters.size == 0
      res = self.send(action)
    else
      raise "Invalid #{type.to_s} '#{action}': expected none or single parameter; got #{method.parameters.size}"
    end

    res
  end

end

