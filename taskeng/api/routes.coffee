internal_commands = require "./internal_commands"

module.exports.register = (server) ->	
	server.get '/ping', internal_commands.get_ping