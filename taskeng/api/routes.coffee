internal_commands = require "./internal_commands"
listeners_commands = require "./listeners_commands"

module.exports.register = (server) ->	
	server.get '/ping', internal_commands.get_ping

	# TODO add secret hash to URL (verified against job) as additional security measure
	server.post '/l/:id', (req, res, next) ->
		listeners_commands.create_event(server.runner, req, res, next)