class DummyService < Provider
  # define filter either for all actions, or limit it with :only => []
  before_filter :do_something, :only => [:ping]

  def ping(request)
    response :ok, :reply => "go #{@animal}"
  end

  def failwhale(request)
    message = request["options"]["message"] || "lazy dog jumped over the fox"

    raise message
  end

private
  def do_something
    @animal = "tiger"
  end

  def secret
    raise "You shouldn't be allowed to call this one."
  end
end
