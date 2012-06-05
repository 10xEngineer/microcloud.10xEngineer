def read_message(socket)
  zmq_format = [:address, nil, :message]

  message = {}
  position = 0
  begin
    socket.recv_string(raw_message = '')
    message[zmq_format[position]] = raw_message unless zmq_format[position].nil?

    position = position + 1
  end while socket.more_parts?

  message
end

def send_message(socket, message)
  socket.send_string message[:address], ZMQ::SNDMORE
  socket.send_string '', ZMQ::SNDMORE
  socket.send_string message[:message], 0
end

