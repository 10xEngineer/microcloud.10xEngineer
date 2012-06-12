class DummyService < Provider
  def ping(request)
    response :ok, :reply => "go tiger!"
  end

  def failwhale(request)
    message = request["options"]["message"] || "lazy dog jumped over the fox"

    raise message
  end

private

  def secret
    raise "You shouldn't be allowed to call this one."
  end
end
