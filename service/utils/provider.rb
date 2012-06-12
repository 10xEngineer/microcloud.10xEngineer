require 'yajl'
require 'facets'

class Provider
  attr_accessor :name, :actions

  def initialize
    @actions = {}
  end

  def self.load_service(name)
    service = "#{name}_service"
    # TODO needed?
    klass = service.camelcase(:upper)

    service_file = File.join(File.dirname(__FILE__), "../providers/#{name}.rb")
    raise "No service provider found: #{service_file}" unless File.exists?(service_file)

    load service_file

    Object.const_get(klass).new
  end

  def fire(_action, request)
    action = _action.to_sym

    # allow only methods defined by the service class
    if self.class.instance_methods(false).include?(action.to_sym)
      m = self.method(action)

      begin
        res = nil
        if m.parameters.size == 1
          res = self.send(action, request)
        elsif m.parameters.size == 0
          res = self.send(action)
        else
          raise "Invalid action '#{action}': expected 0 or 1 parameter!" 
        end

        if res.nil?
          res = response :ok
        end

        res 
      rescue Exception => e
        puts "error=#{e.message}"
        puts e.backtrace

        response :fail, :reason => e.message
      end
    else
      response :fail, :reason => "Action not defined (#{action})"
    end
  end

  def response(res = :ok, options = {})
    res = {
      :status => res
    }

    res[:options] = options unless options.empty?

    res
  end

  
  def self.get(name)
    @@providers[name]
  end

  def self.service_name(klass)
    reg = klass.match /(.*)Service$/
    raise "Unknown service class: #{klass}" unless reg

    reg[1]
  end

end

