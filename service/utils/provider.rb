class Provider
  @@providers = {}

  def initialize(name, &block)
    @name = name
    @actions = {}

    @@providers[name] = self

    instance_eval &block
  end

  def action(name, &block)
    @actions[name] = block
  end

  def fire(action, *params)
    @actions[action].call(params)
  end

  def self.get(name)
    @@providers[name]
  end

end

def load_provider(name, file)
  load file

  Provider.get(name)
end

def service_provider(name, &block)
  Provider.new(name.to_s, &block)
end
